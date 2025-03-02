final class CPistol : CBaseWeapon{
    CPistol(){
        szPModel = "models/p_9mmhandgun.mdl";
        szWModel = "models/w_9mmhandgun.mdl";
        szShellModel = "models/shell.mdl";

        aryFireSound = {"weapons/pl_gun3.wav"};
        
        szProjName = Global::Const::szPistolShot;
        szAnimation = "onehanded";

        flIdleTime = 5;
        flPrimaryTime = 0.2f;

        iPellet = 1;
        iDefaultGive = 12;
        iMaxAmmo1 = 12;
        iSlot = 1;
        iPosition = 23;
        iShellSound = TE_BOUNCE_SHELL;
        vecAccurency = Vector(64, 64, 0);
    }
}