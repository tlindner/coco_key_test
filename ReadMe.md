Color Computer Keyboard Test

This is three programs that run on your color coputer to test the keyboard.

From the provided disk image, type `RUN KT` to run the program chooser.

=Forward=

This program rolls output bits thru the B port of PIA 0 looking for pressed key by reading the A port and looking for low bits. If a key is detected it's symbol is reversed. Joystick buttons are also ckecked.

=Backward=

This program rolls out bits on port A, looking for pressed keys by reading port B.

=CoCo 3 interrupt=

This program does nothing until a keyboard interrupt is generated. Then the joystick buttons are check and possible updated. If no joystick buttons were press port B is rolled one bit at a time and port A is read looking for a low bit. If a key press is detected it's symbol is reversed. A count is kept of the number of interrupts generated.

--

tim lindner

August 2024

tlindner@macmess.org
