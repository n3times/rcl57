# Engine for RCL-57

C library that allows clients to implement a TI-57 emulator.

Clients should use ti57.h for a faithful emulator and penta7.h to implement an enhanced version of the TI-57.

Penta7 brings, among other enhancements:
- the ability to run the emulator much faster that the original TI-57 while slowing down when appropriate, for example on the PAUSE instruction in RUN mode.
- a user friendly LRN mode where instructions are shown with alphanumeric mnemonics such as "RCL 5".
