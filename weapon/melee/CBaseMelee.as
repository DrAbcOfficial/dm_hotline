#include "CCrowbar"

abstract class CBaseMelee : CBaseWeapon, IBaseMelee{
    protected int iSwing;
    protected int iDamage = 100;
    protected TraceResult trHit;
    
    protected float flAttakTime = 0.0f;
    protected float flWallAttackTime = 0.0f;
    protected float flMissAttakTime = 0.0f;
    
    protected array<string> aryMissSound = {};
    protected array<string> aryWallSound = {};
    protected array<string> aryFleshSound = {};

    CBaseEntity@ GetOwner(){
        return g_EntityFuncs.Instance(self.pev.owner);
    }

    void Spawn() override{
        self.m_iClip = -1;
        CBaseWeapon::Spawn();
    }
    
    bool GetItemInfo( ItemInfo& out info ) override{
        info.iMaxAmmo1 = -1;
        info.iMaxAmmo2 = -1;
        info.iMaxClip = WEAPON_NOCLIP;
        info.iSlot = iSlot;
        info.iPosition = iPosition;
        info.iFlags = iFlag;
        info.iWeight = iWeight;    
        return true;
    }
    
    void PrimaryAttack() override{
        if( !Swing( 1 ) )
            SwingAgain();
    }
    void TertiaryAttack() override{
        //近战武器开个鸡儿镜子？
        return;
    }   
    void Smack(){
        g_WeaponFuncs.DecalGunshot( trHit, BULLET_PLAYER_CROWBAR );
    }

    void SwingAgain(){
        Swing( 0 );
    }

    CBaseEntity@ DoAttack(TraceResult tr){
        CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );
        pPlayer.SetAnimation( PLAYER_ATTACK1 ); 
        float flDamage = iDamage;
        if ( self.m_flCustomDmg > 0 )
            flDamage = self.m_flCustomDmg;
        g_WeaponFuncs.ClearMultiDamage();
        if ( self.m_flNextPrimaryAttack + 1 < g_Engine.time )
            pEntity.TraceAttack( self.pev, flDamage, g_Engine.v_forward, tr, DMG_CLUB );  
        else
            pEntity.TraceAttack( self.pev, flDamage * 0.5, g_Engine.v_forward, tr, DMG_CLUB );  
        g_WeaponFuncs.ApplyMultiDamage( self.pev, self.pev );

        return pEntity;
    }

    bool Swing( int fFirst ){
        bool fDidHit = false;

        TraceResult tr;

        Math.MakeVectors( pPlayer.pev.v_angle );
        Vector vecSrc    = pPlayer.GetGunPosition();
        Vector vecEnd    = vecSrc + g_Engine.v_forward * 32;

        g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );

        if ( tr.flFraction >= 1.0 ){
            g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, pPlayer.edict(), tr );
            if ( tr.flFraction < 1.0 ){
                CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
                if ( pHit is null || pHit.IsBSPModel() )
                    g_Utility.FindHullIntersection( vecSrc, tr, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, pPlayer.edict() );
                vecEnd = tr.vecEndPos;
            }
        }

        if ( tr.flFraction >= 1.0 ){
            if( fFirst != 0 ){
                g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, aryMissSound[Math.RandomLong( 0, aryMissSound.length() - 1 )], 
                    1, ATTN_NORM, 0, 100 + Math.RandomLong( 0,0xF ) );
                pPlayer.SetAnimation( PLAYER_ATTACK1 ); 
                
                self.m_flNextPrimaryAttack = g_Engine.time + flMissAttakTime;
            }
        }
        else{
            fDidHit = true;
            CBaseEntity@ pEntity = DoAttack(tr);
            float flVol = 1.0;
            bool fHitWorld = true;

            if( pEntity !is null ){
                self.m_flNextPrimaryAttack = g_Engine.time + flAttakTime;
                if( pEntity.Classify() != CLASS_NONE && pEntity.Classify() != CLASS_MACHINE && pEntity.BloodColor() != DONT_BLEED ){
                    if( pEntity.IsPlayer() )
                        pEntity.pev.velocity = pEntity.pev.velocity + ( self.pev.origin - pEntity.pev.origin ).Normalize() * 120;

                    g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_WEAPON, aryFleshSound[Math.RandomLong( 0, aryFleshSound.length() - 1 )], 1, ATTN_NORM );
                    
                    pPlayer.m_iWeaponVolume = 128; 
                    if( !pEntity.IsAlive() )
                        return true;
                    else
                        flVol = 0.1;
                        
                    fHitWorld = false;
                }
            }

            if( fHitWorld == true ){
                float fvolbar = g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + ( vecEnd - vecSrc ) * 2, BULLET_PLAYER_CROWBAR );
                
                self.m_flNextPrimaryAttack = g_Engine.time + flWallAttackTime;
                fvolbar = 1;
                g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, 
                    aryWallSound[Math.RandomLong( 0, aryWallSound.length() - 1 )], fvolbar, ATTN_NORM, 0, 100 + Math.RandomLong( 0, 3 ) ); 
            }

            trHit = tr;
            Smack();

            pPlayer.m_iWeaponVolume = int( flVol * 512 ); 
        }
        return fDidHit;
    }
}