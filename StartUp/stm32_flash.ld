/*----------------------------------------------------------------------------
   \brief   linker script file for stm32f0 controller
            This version has to be used when application is running in
            flash memory.
   \author  Maximilian Seesslen <mes@seesslen.net>
   \date    <20130403> file created
----------------------------------------------------------------------------*/
/* Entry Point */
ENTRY(Reset_Handler)
EXTERN(
   /*override_Handler*/
   /* Referning to an weak symbol seems to be sufficient. */
   SysTick_Handler
)
/* Generate a link error if heap and stack don't fit into RAM */
_Min_Heap_Size = 0x1000;      /* required amount of heap  */
_Min_Stack_Size = 0x1000; /* required amount of stack */
/* Specify the memory areas */
MEMORY
{
  FLASH (rx)      : ORIGIN = 0x08000000, LENGTH = 128K
  RAM (xrw)       : ORIGIN = 0x20000000, LENGTH = 16K
  MEMORY_B1 (rx)  : ORIGIN = 0x60000000, LENGTH = 0K
}
_eflash = ORIGIN(FLASH) + LENGTH(FLASH);
_eram = ORIGIN(RAM) + LENGTH(RAM);
/* Highest address of the user mode stack */
_estack = ORIGIN(RAM) + LENGTH(RAM);
/* Define output sections */
SECTIONS
{
  /* The startup code goes first into FLASH */
  .isr_vector :
  {
     /*PROVIDE ( very_start = . );*/
    . = ALIGN(4);
    KEEP(*(.isr_vector)) /* Startup code */
    . = ALIGN(4);
  } >FLASH
  /* The program code and other data goes into FLASH */
  .text :
  {
    . = ALIGN(4);
    *(.text)           /* .text sections (code) */
    *(.text*)          /* .text* sections (code) */
    *(.rodata)         /* .rodata sections (constants, strings, etc.) */
    *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
    *(.glue_7)         /* glue arm to thumb code */
    *(.glue_7t)        /* glue thumb to arm code */
   *(.eh_frame)
    KEEP (*(.init))
    KEEP (*(.fini))
    . = ALIGN(4);
    _etext = .;        /* define a global symbols at end of code */
  } >FLASH
   .ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >FLASH
    .ARM : {
    __exidx_start = .;
      *(.ARM.exidx*)
      __exidx_end = .;
    } >FLASH
  .preinit_array     :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array*))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >FLASH
  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array*))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >FLASH
  .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(.fini_array*))
    KEEP (*(SORT(.fini_array.*)))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } >FLASH
  /* used by the startup to initialize data */
  _sidata = .;
  /* Initialized data sections goes into RAM, load LMA copy after code */
  /*.dynamic        : { *(.dynamic) }*/
  /*.got            : { *(.got.plt) *(.got) }*/
  .data : AT ( _sidata )
  {
    . = ALIGN(4);
    _sdata = .;        /* create a global symbol at data start */
    *(.data)           /* .data sections */
    *(.data*)          /* .data* sections */
    *(.dynamic)
    /**(.got*)*/          /* i dont know */
    *(.got.plt)
    *(.got)
    . = ALIGN(4);
    _edata = .;        /* define a global symbol at data end */
  } >RAM
  /* Uninitialized data section */
  . = ALIGN(4);
  .bss :
  {
    /* This is used by the startup in order to initialize the .bss secion */
    _sbss = .;         /* define a global symbol at bss start */
    __bss_start__ = _sbss;
    *(.bss)
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;         /* define a global symbol at bss end */
    __bss_end__ = _ebss;
  } >RAM
  /* User_heap_stack section, used to check that there is enough RAM left */
  ._user_heap_stack :
  {
    . = ALIGN(4);
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    heap_low = .; /* for _sbrk */
    . = . + _Min_Heap_Size;
    heap_top = .; /* for _sbrk */
    . = . + _Min_Stack_Size;
    stack_top = .; /* for startup.s */
    . = ALIGN(4);
  } >RAM
  /* Remove information from the standard libraries */
  /DISCARD/ :
  {
    libc.a ( * )
    libstdc++.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }
  .ARM.attributes 0 : { *(.ARM.attributes) }
}
/*---fin--------------------------------------------------------------------*/