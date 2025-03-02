final class CShotGun : CBaseWeapon{
    CShotGun(){
        szPModel = "models/p_shotgun.mdl";
        szWModel = "models/w_shotgun.mdl";
        szShellModel = "models/shotgunshell.mdl";

        aryFireSound = {"weapons/dbarrel2.wav"};
        
        szProjName = Global::Const::szShotShot;
        szAnimation = "shotgun";

        flIdleTime = 5;
        flPrimaryTime = 0.45f;

        iPellet = 8;
        iDefaultGive = 8;
        iMaxAmmo1 = 8;
        iSlot = 1;
        iPosition = 25;
        iShellSound = TE_BOUNCE_SHOTSHELL;
        vecAccurency = Vector(256, 256, 0);
    }
}