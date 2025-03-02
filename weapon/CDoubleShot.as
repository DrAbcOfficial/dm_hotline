final class CDoubleShot : CBaseWeapon{
    CDoubleShot(){
        szPModel = "models/hunger/weapons/dbarrel/p_dbarrel.mdl";
        szWModel = "models/hunger/weapons/dbarrel/w_dbarrel.mdl";
        szShellModel = "models/shotgunshell.mdl";

        aryFireSound = {"hunger/weapons/dbarrel/fire.wav"};
        
        szProjName = Global::Const::szShotShot;
        szAnimation = "shotgun";

        flIdleTime = 5;
        flPrimaryTime = 0.2f;

        iPellet = 16;
        iDefaultGive = 2;
        iMaxAmmo1 = 2;
        iSlot = 1;
        iPosition = 21;
        iShellSound = TE_BOUNCE_SHOTSHELL;
        vecAccurency = Vector(1024, 1024, 0);
    }
}