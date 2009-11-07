with Ada.Text_IO;
with Ada.Strings.Unbounded;

package Getline is

  procedure Get
    (File : in Ada.Text_IO.File_Type;
     Item : out Ada.Strings.Unbounded.Unbounded_String);

end Getline;
