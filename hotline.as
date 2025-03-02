#include "entity/CViewer"
#include "entity/projectile/IBaseProjectile"
#include "entity/projectile/CBaseProjectile"

#include "weapon/CBaseWeapon"
#include "weapon/melee/CBaseMelee"
#include "weapon/melee/IBaseMelee"

namespace Debugger{
    void Log(string s){
        g_Log.PrintF("[DM HOTLINE]" + s + "\n");
    }
}
namespace Global{
    namespace Const{
        const string szViewerName = "info_hotline_viewer";

        const string szMagnumShot = "proj_hotline_mugnum";
        const string szPistolShot = "proj_hotline_pistol";
        const string szRifleShot = "proj_hotline_rifle";
        const string szShotShot = "proj_hotline_shot";

        const string szMagnum = "weapon_hotline_magnum";
        const string szDoubleShot = "weapon_hotline_doubleshot";
        const string szPistol = "weapon_hotline_pistol";
        const string szRifle = "weapon_hotline_rifle";
        const string szShotgun = "weapon_hotline_shotgun";
        const string szMachineGun = "weapon_hotline_machinegun";
        const string szSniper = "weapon_hotline_sniper";

        const string szCrowbar = "weapon_hotline_crowbar";

        const string szSprDir = "dm_hotline";
        //十倍伤害
        const float flDamageTweak = 10.0f;
        //视角高度
        const float flViewDistance = 400.0f;
    }
    array<EHandle> aryViewEntity(33);
    array<float> aryZoomedPlayer(33);
}

void PluginInit(){
    g_Module.ScriptInfo.SetAuthor( "drabc" );
    g_Module.ScriptInfo.SetContactInfo( "dmdmdm" );
}
void MapInit(){
    g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
    g_Hooks.RegisterHook( Hooks::Player::PlayerTakeDamage, @PlayerTakeDamage );
    g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
    g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @PlayerPostThink );

    EntityRegister( "CViewer", Global::Const::szViewerName);
    EntityRegister( "CPistolShot", Global::Const::szPistolShot);
    EntityRegister( "CRifleShot", Global::Const::szRifleShot);
    EntityRegister( "CShotShot", Global::Const::szShotShot);
    EntityRegister( "CMagumShot", Global::Const::szMagnumShot);

    WeaponRegister("CDoubleShot", Global::Const::szDoubleShot);
    WeaponRegister("CMagnum", Global::Const::szMagnum);
    WeaponRegister("CPistol", Global::Const::szPistol);
    WeaponRegister("CRifle", Global::Const::szRifle);
    WeaponRegister("CShotGun", Global::Const::szShotgun);
    WeaponRegister("CMachineGun", Global::Const::szMachineGun);
    WeaponRegister("CSniper", Global::Const::szSniper);

    WeaponRegister("CCrowbar", Global::Const::szCrowbar, true);
    
}
HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer ){
    //设置视角到天上
    Vector vecOrigin = pPlayer.pev.origin;
    CBaseEntity@ pEntity = g_EntityFuncs.Create(Global::Const::szViewerName, 
        vecOrigin, Vector(90, 0 , 0), false, pPlayer.edict());
    Global::aryViewEntity[pPlayer.entindex()] = EHandle(@pEntity);
    
    return HOOK_CONTINUE;
}
HookReturnCode PlayerTakeDamage(DamageInfo@ info){
    //伤害调整
    info.flDamage *= Global::Const::flDamageTweak;
    IBaseProjectile@ iInflictor = cast<IBaseProjectile@>(CastToScriptClass(info.pInflictor));
    CBaseEntity@ pRealAttacker = null;
    if(@iInflictor !is null)
        @pRealAttacker = iInflictor.GetOwner();
    else{
        IBaseMelee@ iMelee = cast<IBaseMelee@>(CastToScriptClass(info.pInflictor));
        if(@iMelee !is null)
            @pRealAttacker = iMelee.GetOwner();
        else
            return HOOK_CONTINUE;
    }
    if(@pRealAttacker !is null){
        CBasePlayer@ pPlayer = cast<CBasePlayer@>(info.pVictim);
        CBaseEntity@ pAttacker = info.pAttacker;
        CBaseEntity@ pInflictor = info.pInflictor;
        float flDamage = info.flDamage;
        info.flDamage = 0;
        if(pAttacker is null || pInflictor is null || pPlayer is null)
            return HOOK_CONTINUE;
        if(!pPlayer.IsAlive())
            return HOOK_CONTINUE;
        int bitsDamageType = info.bitsDamageType;
        float flRatio = 0.2;
        float flBonus = 0.5;
        if( pPlayer.m_LastHitGroup == HITGROUP_HEAD)
            flDamage *= 3;
        if ( bitsDamageType & DMG_BLAST != 0)
            flBonus *= 2;
        pPlayer.m_lastDamageAmount = flDamage;
        if (pPlayer.pev.armorvalue > 0 && pAttacker.entindex() != 0 && (bitsDamageType & (DMG_FALL | DMG_DROWN) == 0) ){
            float flNew = flDamage * flRatio;
            float flArmor;
            flArmor = (flDamage - flNew) * flBonus;
            if (flArmor > pPlayer.pev.armorvalue){
                flArmor = pPlayer.pev.armorvalue;
                flArmor *= (1/flBonus);
                flNew = flDamage - flArmor;
                pPlayer.pev.armorvalue = 0;
            }
            else
                pPlayer.pev.armorvalue -= flArmor;
            flDamage = flNew;
        }
        Vector vecDir = Vector( 0, 0, 0 );
        pPlayer.m_bitsDamageType |= bitsDamageType;
        if (pInflictor !is null)
            vecDir = ( pInflictor.Center() - Vector ( 0, 0, 10 ) - pPlayer.Center() ).Normalize();
        @pPlayer.pev.dmg_inflictor = pInflictor.edict();
        pPlayer.pev.dmg_take += flDamage;
        
        TraceResult tr = g_Utility.GetGlobalTrace();
        if(tr.pHit is pPlayer.edict())
            g_Utility.BloodDrips(tr.vecEndPos, g_Utility.RandomBloodVector(), pPlayer.BloodColor(), int(flDamage));

        if ( (pPlayer.pev.movetype == MOVETYPE_WALK) && (pAttacker !is null || pAttacker.pev.solid != SOLID_TRIGGER) )
            pPlayer.pev.velocity = pPlayer.pev.velocity + vecDir * - pPlayer.DamageForce( flDamage );
        float flPrveHealth = pPlayer.pev.health;
        pPlayer.pev.health -= flDamage;
        CBasePlayer@ pKiller = cast<CBasePlayer@>(g_EntityFuncs.Instance(pAttacker.pev.owner));
        if ( pPlayer.pev.health < 1 ){
            entvars_t@ pevVars = pAttacker.pev.owner !is null ? @pAttacker.pev.owner.vars : @pAttacker.pev;
            if ( bitsDamageType & DMG_ALWAYSGIB != 0)
                pPlayer.Killed( pevVars, GIB_ALWAYS );
            else if ( bitsDamageType & DMG_NEVERGIB != 0)
                pPlayer.Killed( pevVars, GIB_NEVER );
            else
                pPlayer.Killed( pevVars, GIB_NORMAL );
            if (@pPlayer !is pAttacker)
                pPlayer.m_iDeaths++;
        }
    }
    return HOOK_CONTINUE;
}
HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int bitGib ){
    if(Global::aryViewEntity[pPlayer.entindex()].IsValid())
        g_EntityFuncs.Remove(Global::aryViewEntity[pPlayer.entindex()]);
    return HOOK_CONTINUE;
}
HookReturnCode PlayerPostThink( CBasePlayer@ pPlayer ){
    pPlayer.SetItemPickupTimes(0);
    pPlayer.SetViewMode(ViewMode_ThirdPerson);
    return HOOK_CONTINUE;
}
void WeaponRegister(string szClassName, string szWeaponName, bool bMelle = false){
    g_CustomEntityFuncs.RegisterCustomEntity( szClassName, szWeaponName );
    g_ItemRegistry.RegisterWeapon( szWeaponName, Global::Const::szSprDir, bMelle ? "" : szWeaponName);
    g_Game.PrecacheOther(szWeaponName);
}
void EntityRegister(string szClassName, string szEntityName){
    g_CustomEntityFuncs.RegisterCustomEntity( szClassName, szEntityName );
    g_Game.PrecacheOther(szEntityName);
}