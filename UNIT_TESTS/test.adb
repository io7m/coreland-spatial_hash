with Ada.Text_IO;

package body Test is
  package IO renames Ada.Text_IO;

  procedure Sys_Exit (Code : Integer);
  pragma Import (C, Sys_Exit, "exit");

  Current_Test : Natural := 0;

  procedure Assert
   (Check        : in Boolean;
    Pass_Message : in String := "assertion passed";
    Fail_Message : in String := "assertion failed") is
  begin
    Current_Test := Current_Test + 1;
    if Check then
      IO.Put_Line (IO.Current_Error, "pass:" & Natural'Image (Current_Test) & ": " & Pass_Message);
    else
      IO.Put_Line (IO.Current_Error, "fail:" & Natural'Image (Current_Test) & ": " & Fail_Message);
      Sys_Exit (1);
    end if;
  end Assert;

end Test;
