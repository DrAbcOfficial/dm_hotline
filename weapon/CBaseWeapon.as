#include "CDoubleShot"
#include "CMagnum"
#include "CPistol"
#include "CRifle"
#include "CShotGun"
#include "CMachineGun"
#include "CSniper"

abstract class CBaseWeapon : ScriptBasePlayerWeaponEntity {
   protected CBasePlayer@ pPlayer = null;

    protected string szPModel = "";
    protected string szWModel = "";
    protected string szShellModel = "";
    protected string szAnimation = "";
    protected string szProjName = "";
    protected int iShell = 0;

    protected float flDeploy = 0.0f;
    protected float flIdleTime = 0;
    protected float flPrimaryTime = 0;
    protected float flBulletSpeed = 1400;
    protected float flRotateSpeed = 30;
    protected float flZoom = 128;

    protected int iPellet = 0;
    protected int iDefaultGive = 0;
    protected int iMaxAmmo1 = 0;
    protected int iSlot = 0;
    protected int iPosition = 0;
    protected int iFlag = ITEM_FLAG_NOAUTORELOAD | ITEM_FLAG_NOAUTOSWITCHEMPTY;
    protected int iWeight = 0;
    protected TE_BOUNCE iShellSound = TE_BOUNCE_SHELL;

    protected Vector vecEjectOrigin = Vector(18, 8, -6);
    protected Vector vecAccurency = g_vecZero;

    protected Vector2D vec2XPunch = Vector2D(0, 0);
    protected Vector2D vec2YPunch = Vector2D(0, 0);
    protected Vector2D vecDamageDrift = Vector2D(-1, 1);

    protected string szEmptySound = "hl/weapons/357_cock1.wav";
    protected string szDropSound = "weapons/cbar_miss1.wav";
    protected array<string>@ aryFireSound = {};

    protected bool bEmpty = false;
    protected bool bZoomFlag = false;
    protected bool bEmptyDropFlag = false;

    void Spawn(){
        BaseClass.Spawn();
        Precache();
        g_EntityFuncs.SetModel(self, szWModel);
        self.m_iDefaultAmmo = iDefaultGive;
        self.pev.avelocity.y = flRotateSpeed;
        self.KeyValue("exclusivehold", "1");
        self.pev.movetype = MOVETYPE_FLY;
    }
    void Precache(){
        g_Game.PrecacheModel( szWModel );
        g_Game.PrecacheGeneric( szWModel);
        g_Game.PrecacheModel( szPModel );
        g_Game.PrecacheGeneric( szPModel);

        if(!szShellModel.IsEmpty()){
            iShell = g_Game.PrecacheModel( szShellModel );
            g_Game.PrecacheGeneric( szShellModel);
        }
        g_SoundSystem.PrecacheSound( szEmptySound );
        g_Game.PrecacheGeneric( "sound/" + szEmptySound );
        g_SoundSystem.PrecacheSound( szDropSound );
        g_Game.PrecacheGeneric( "sound/" + szDropSound );
        for(uint i = 0; i < aryFireSound.length(); i++){
            g_SoundSystem.PrecacheSound( aryFireSound[i] );
            g_Game.PrecacheGeneric( "sound/" + aryFireSound[i]);
        }
        g_Game.PrecacheGeneric( "sprites/" + Global::Const::szSprDir + "/" + self.pev.classname + ".txt");
    }
    bool GetItemInfo( ItemInfo& out info ){
        info.iMaxAmmo1    = iMaxAmmo1;
        info.iMaxAmmo2    = 0;
        info.iMaxClip    = 0;
        info.iSlot        = iSlot;
        info.iPosition    = iPosition;
        info.iFlags        = iFlag;
        info.iWeight    = iWeight;
        return true;
    }
    bool AddToPlayer( CBasePlayer@ pPlayer ){
        if(bEmpty)
            return false;
        if( BaseClass.AddToPlayer (pPlayer)){
            @this.pPlayer = pPlayer;
            NetworkMessage m( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
                m.WriteLong( g_ItemRegistry.GetIdForName(self.pev.classname) );
            m.End();
            return true;
        }
        return false;
    }
    bool PlayEmptySound(){
        if( self.m_bPlayEmptySound ){
            self.m_bPlayEmptySound = false;
            g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, szEmptySound, 0.9, ATTN_NORM, 0, PITCH_NORM );
        }
        return false;
    }
    float WeaponTimeBase(){
        return g_Engine.time;
    }
    void Holster( int skipLocal = 0 ) {
        self.m_fInReload = false;
        SetThink( null );
        pPlayer.pev.viewmodel = "";
        StopZoom();
        BaseClass.Holster( skipLocal );
    }
    void Materialize(){
        if(bEmpty)
            self.pev.avelocity.y = flRotateSpeed;
        BaseClass.Materialize();
    }
    bool Deploy(){
        bool bResult = self.DefaultDeploy ( self.GetV_Model( szPModel ), self.GetP_Model( szPModel ), 0, szAnimation );
        self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flDeploy;
        return bResult;
    }
    CBaseEntity@ ShotFire(Vector vecSrc, Vector vecAcc, float flShotSpeed){
        Vector vecAngle = pPlayer.pev.v_angle + pPlayer.pev.punchangle;
        vecAngle.x = 0;
        Math.MakeVectors( vecAngle );
        CBaseEntity@ pEntity = g_EntityFuncs.Create(szProjName, vecSrc, g_vecZero, true, pPlayer.edict());
        float x, y;
        float flSpeed = pPlayer.pev.velocity.Length();
        g_Utility.GetCircularGaussianSpread(x, y);
        Vector vecVelocity = g_Engine.v_forward * flShotSpeed + 
            g_Engine.v_right * (vecAcc.x + flSpeed) * x + 
            g_Engine.v_up * (vecAcc.y + flSpeed) * y;
        vecVelocity.z = 0;
        pEntity.pev.velocity = vecVelocity;
        @pEntity.pev.owner = pPlayer.edict();
        g_EngineFuncs.VecToAngles( pEntity.pev.velocity, pEntity.pev.angles );
        pEntity.pev.groupinfo = pPlayer.entindex();
        g_EntityFuncs.DispatchSpawn(pEntity.edict());
        return @pEntity;
    }
    void Reload(){
        return;
    }
    void DropEmpty(){
        Vector vecAngle = pPlayer.pev.v_angle + pPlayer.pev.punchangle;
        Math.MakeVectors( vecAngle );
        CBaseEntity@ pEntity = g_EntityFuncs.Create("info_target", pPlayer.Center(), g_vecZero, true, pPlayer.edict());
        g_EntityFuncs.SetModel(@pEntity, szWModel);
        float x, y;
        float flSpeed = pPlayer.pev.velocity.Length();
        g_Utility.GetCircularGaussianSpread(x, y);
        Vector vecVelocity = g_Engine.v_forward * 300 + 
            g_Engine.v_right *flSpeed * x + 
            g_Engine.v_up * flSpeed * y;
        pEntity.pev.angles.y = Math.RandomFloat(0, 360);
        pEntity.pev.movetype = MOVETYPE_TOSS;
        pEntity.pev.solid = SOLID_NOT;
        pEntity.pev.velocity = vecVelocity;
        g_EngineFuncs.VecToAngles( pEntity.pev.velocity, pEntity.pev.angles );
        g_EntityFuncs.DispatchSpawn(pEntity.edict());
        g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, szDropSound, 0.9, ATTN_NORM, 0, PITCH_NORM );
        pEntity.SUB_StartFadeOut();
        g_EntityFuncs.Remove(self);
    }
    void PrimaryAttack(){
        //躲避时不允许开枪
        if(pPlayer.pev.flags & FL_ONGROUND == 0)
            return;
        if(bEmptyDropFlag)
            return;
        if(!bEmptyDropFlag && bEmpty){
            DropEmpty();
            return;
        }
        if(pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0){
            bEmpty = true;
            self.PlayEmptySound();
            self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
            return;
        } 
        self.m_flTimeWeaponIdle = WeaponTimeBase() + flIdleTime;
        self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + flPrimaryTime;

        pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1);
        
        pPlayer.pev.effects |= EF_MUZZLEFLASH;
        pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
        pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
        pPlayer.SetAnimation( PLAYER_ATTACK1 );

        if(aryFireSound.length() > 0){
            g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, 
            aryFireSound[g_PlayerFuncs.SharedRandomLong(pPlayer.random_seed, 0, aryFireSound.length() - 1)], 
            0.9, ATTN_NORM, 0, PITCH_NORM );
        }
        
        for(int i = 0; i < iPellet; i++){
            ShotFire(pPlayer.Center(), vecAccurency, flBulletSpeed);
        }
        
        Vector vecSrc = pPlayer.GetGunPosition();
        NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
            m.WriteByte(TE_DLIGHT);
            m.WriteCoord(vecSrc.x);
            m.WriteCoord(vecSrc.y);
            m.WriteCoord(vecSrc.z);
            m.WriteByte(16);
            m.WriteByte(255);
            m.WriteByte(255);
            m.WriteByte(34);
            m.WriteByte(1);
            m.WriteByte(255);
        m.End();

        if( pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
            pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
        
        pPlayer.pev.punchangle.x += Math.RandomFloat( vec2XPunch.x, vec2XPunch.y );
        pPlayer.pev.punchangle.y += Math.RandomFloat( vec2YPunch.x, vec2YPunch.y );

        Vector vecShellOffset =  vecEjectOrigin;
        Vector vecShellOrigin = g_Engine.v_right * vecShellOffset.x + g_Engine.v_forward * vecShellOffset.y + g_Engine.v_up * vecShellOffset.z;

        g_EntityFuncs.EjectBrass( 
            pPlayer.GetGunPosition() + vecShellOrigin, 
            g_Engine.v_right * Math.RandomLong(80,160) + g_Engine.v_forward * Math.RandomLong(-20,80) + pPlayer.pev.velocity, 
            pPlayer.pev.angles[1], 
            iShell, 
            iShellSound );

        if(pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0){
            bEmptyDropFlag = true;
            bEmpty = true;
        } 
    }
    void SecondaryAttack(){
        CBaseEntity@ pEntity = ShotFire(pPlayer.Center(), vecAccurency, 800);
        pEntity.pev.movetype = MOVETYPE_TOSS;
        g_EntityFuncs.SetModel(@pEntity, szWModel);
        pEntity.pev.gravity = 0.4;
        pEntity.pev.avelocity.y = 150;
        pEntity.pev.renderamt = 255;
        pEntity.pev.scale = 1;
        pEntity.pev.rendermode = kRenderNormal;
        g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, szDropSound, 0.9, ATTN_NORM, 0, PITCH_NORM );
        self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 999;
        g_EntityFuncs.Remove(self);
    }
    void StopZoom(){
        Global::aryZoomedPlayer[pPlayer.entindex()] = 0;
    }
    void StartZoom(){
        Global::aryZoomedPlayer[pPlayer.entindex()] = flZoom;
    }
    void TertiaryAttack(){
        if(bZoomFlag)
            return;
        bZoomFlag = true;
        if(Global::aryZoomedPlayer[pPlayer.entindex()] != 0)
            StopZoom();
        else
            StartZoom();
        self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flNextTertiaryAttack = WeaponTimeBase() + 0.1;
    }
    void WeaponIdle(){
        if(bZoomFlag)
            bZoomFlag = false;
        if(bEmptyDropFlag)
            bEmptyDropFlag = false;
        self.ResetEmptySound();
        if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
            return;
        self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
    }
}