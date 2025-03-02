final class CMachineGun : CBaseWeapon {
    CMachineGun(){
        szPModel = "models/p_saw.mdl";
        szWModel = "models/w_saw.mdl";
        szShellModel = "models/saw_shell.mdl";

        aryFireSound = {"weapons/saw_fire1.wav"};
        
        szProjName = Global::Const::szRifleShot;
        szAnimation = "saw";

        flIdleTime = 5;
        flPrimaryTime = 0.08f;

        iPellet = 1;
        iDefaultGive = 80;
        iMaxAmmo1 = 80;
        iSlot = 1;
        iPosition = 19;
        iShellSound = TE_BOUNCE_SHELL;
        vecAccurency = Vector(800, 800, 0);
    }
}