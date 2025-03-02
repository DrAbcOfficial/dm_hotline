final class CSniper : CBaseWeapon {
    CSniper(){
        szPModel = "models/p_m40a1.mdl";
        szWModel = "models/w_m40a1.mdl";
        szShellModel = "models/saw_shell.mdl";

        aryFireSound = {"weapons/sniper_fire.wav"};
        
        szProjName = Global::Const::szMagnumShot;
        szAnimation = "sniper";

        flBulletSpeed = 3000;
        flZoom = 512;
        flIdleTime = 5;
        flPrimaryTime = 0.5f;

        iPellet = 1;
        iDefaultGive = 5;
        iMaxAmmo1 = 5;
        iSlot = 1;
        iPosition = 18;
        iShellSound = TE_BOUNCE_SHELL;
        vecAccurency = Vector(0, 0, 0);
    }
}