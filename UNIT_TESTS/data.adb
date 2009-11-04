package body Data is

  procedure Bounding_Box
    (Entity_ID : in     Entity_ID_t;
     Top       :    out Float;
     Bottom    :    out Float;
     Left      :    out Float;
     Right     :    out Float) is
  begin
    Top    := Float (Entity_ID);
    Bottom := Top + 1.0;
    Left   := Top;
    Right  := Top + 1.0;
  end Bounding_Box;

end Data;
