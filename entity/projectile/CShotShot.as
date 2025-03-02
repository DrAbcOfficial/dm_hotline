final class CShotShot : CBaseProjectile, IBaseProjectile, ScriptBaseEntity{
    CShotShot(){
        szModel = "models/dm_hotline/proj_blue.mdl";
        iDamage = 25;
        flScale = 0.45;
    }
}