package body Data is

  procedure Bounding_Box
    (Entity : in     Entity_ID_t;
     Bottom :    out Integer;
     Height :    out Integer;
     Left   :    out Integer;
     Width  :    out Integer) is
  begin
    Bottom := Integer (Entity);
    Height := 1;
    Left   := Integer (Entity);
    Width  := 1;
  end Bounding_Box;

end Data;
