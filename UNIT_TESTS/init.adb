with Ada.Containers;
with Data;
with Test;

procedure Init is
  use type Ada.Containers.Count_Type;
begin
  Test.Assert (Data.Spatial_Hashing.Count_Active_Cells (Data.Spatial_Hash) = 0);
  Test.Assert (Data.Spatial_Hashing.Count              (Data.Spatial_Hash) = 0);

  Data.Spatial_Hashing.Active_Cells
    (Spatial_Hash => Data.Spatial_Hash,
     Cells        => Data.Active_Cells);
  Test.Assert (Data.Spatial_Hashing.Cell_Sets.Length (Data.Active_Cells) = 0);

  Data.Spatial_Hashing.Entities_For_Cell
    (Spatial_Hash => Data.Spatial_Hash,
     Cell         => 1,
     Entities     => Data.Entities);

  Test.Assert (Data.Entity_Sets.Length (Data.Entities) = 0);
end Init;
