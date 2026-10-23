Alintosh Machine 8-bit Operating System (AM8 OS)

    this is minimal Operating System (OS) For AM8.
    NO SHELL, SO DO NOT TYPE IN KEYBOARD.
    Very minimal even no many utils.
    Features:
        IDT
        GDT
        IO
        Keyboard
        Input Function
        String Functions
    Q: How This Work ?
    A: Edit 'modules/test.s' by AM8 Machine Language, then make it.
    Q: How To Make It ?
    A: To make it, run:
        make
       If you want to run it, run:
        make run_qemu
       To clean:
        make clean
       Or, Try this to build and run then clean autocomally :
        make && make run_qemu; make clean
    
    READ AM8 LANG. MANUAL AT https://github.com/ali25353543/am8