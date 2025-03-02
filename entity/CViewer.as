final class CViewer : ScriptBaseEntity{
    void Spawn(){
        BaseClass.Spawn();
        g_EntityFuncs.SetModel(self, "models/player.mdl");
        self.pev.rendermode = kRenderTransAdd;
        self.pev.renderamt = 0;
        self.pev.solid = SOLID_NOT;
        self.pev.movetype = MOVETYPE_NOCLIP;
        self.pev.nextthink = g_Engine.time + 0.5;
    }
    void Think(){
        g_EngineFuncs.SetView(self.pev.owner, self.edict());
        SetThink(ThinkFunction(@UpdateThink));
        self.pev.nextthink = g_Engine.time;
    }
    void UpdateThink(){
        CBaseEntity@ pOwner = g_EntityFuncs.Instance(self.pev.owner);
        if(pOwner is null || !pOwner.IsAlive()){
            g_EntityFuncs.Remove(self);
            return;
        }
        
        //地图跟随视角旋转
        //self.pev.angles.y = pOwner.pev.angles.y;
        self.pev.origin.x = pOwner.pev.origin.x;
        self.pev.origin.y = pOwner.pev.origin.y;
        self.pev.origin.z = pOwner.pev.origin.z + Global::Const::flViewDistance;
        if(Global::aryZoomedPlayer[pOwner.entindex()] > 0){
            Math.MakeVectors(pOwner.pev.angles);
            Vector vecZoom = g_Engine.v_forward * Global::aryZoomedPlayer[pOwner.entindex()];
            vecZoom.z = 0;
            self.pev.origin = self.pev.origin + vecZoom;
        }
        self.pev.nextthink = g_Engine.time;
    }
}