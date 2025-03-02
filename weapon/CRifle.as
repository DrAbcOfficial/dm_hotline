final class CRifle : CBaseWeapon{
    CRifle(){
        szPModel = "models/p_m16.mdl";
        szWModel = "models/w_m16.mdl";
        szShellModel = "models/shell.mdl";

        aryFireSound = {"weapons/m16_single.wav"};
        
        szProjName = Global::Const::szRifleShot;
        szAnimation = "m16";

        flIdleTime = 5;
        flPrimaryTime = 0.07f;

        iPellet = 1;
        iDefaultGive = 30;
        iMaxAmmo1 = 30;
        iSlot = 1;
        iPosition = 24;
        iShellSound = TE_BOUNCE_SHELL;
        vecAccurency = Vector(128, 128, 0);
    }
}