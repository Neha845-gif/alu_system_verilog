class alu_test;
    // Virtual interfaces
    virtual alu_if drv_vif;    // Driver interface
    virtual alu_if mon_vif;    // Monitor interface
    virtual alu_if ref_vif;    // Reference model interface

    // Environment handle
    alu_environment env;

    // Constructor
    function new(virtual alu_if drv_vif,
                 virtual alu_if mon_vif,
                 virtual alu_if ref_vif);
        this.drv_vif = drv_vif;
        this.mon_vif = mon_vif;
        this.ref_vif = ref_vif;
    endfunction

    // Main run task
    task run();
        // Create environment instance
        env = new(drv_vif, mon_vif, ref_vif);

        // Build the environment components
        env.build();

        // Start all components
        env.start();
    endtask
endclass
