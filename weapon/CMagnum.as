final class CMagnum : CBaseWeapon{
    CMagnum(){
        szPModel = "models/p_357.mdl";
        szWModel = "models/w_357.mdl";
        szShellModel = "models/shell.mdl";

        aryFireSound = {"weapons/357_shot1.wav"};
        
        szProjName = Global::Const::szMagnumShot;
        szAnimation = "python";

        flIdleTime = 5;
        flPrimaryTime = 0.35f;

        iPellet = 1;
        iDefaultGive = 6;
        iMaxAmmo1 = 6;
        iSlot = 1;
        iPosition = 22;
        iShellSound = TE_BOUNCE_SHELL;
        vecAccurency = Vector(64, 64, 0);
    }
}