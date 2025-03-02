final class CCrowbar : CBaseMelee {
    CCrowbar(){
        szPModel = "models/p_crowbar.mdl";
        szWModel = "models/w_crowbar.mdl";
        
        szAnimation = "crowbar";
        szProjName = Global::Const::szPistolShot;
        
        //your last weapon
        iFlag = 0;

        flIdleTime = 5;
        flPrimaryTime = 0.75f;
        flAttakTime = 0.75f;
        flWallAttackTime = 0.3f;
        flMissAttakTime = 0.75f;

        iSlot = 0;
        iPosition = 20;
        iDamage = 100;

        aryMissSound = {"weapons/cbar_miss1.wav"};
        aryWallSound = {"weapons/cbar_hit1.wav", "weapons/cbar_hit2.wav"};
        aryFleshSound = {"weapons/cbar_hitbod1.wav", "weapons/cbar_hitbod2.wav", "weapons/cbar_hitbod3.wav"};
    }
    void Spawn() override{
        CBaseMelee::Spawn();
        //your last weapon
        self.KeyValue("exclusivehold", "0");
    }
    void SecondaryAttack() override{
        //your last weapon
        return;
    }
}