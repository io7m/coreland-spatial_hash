with Ada.Containers.Hashed_Sets;
with Spatial_Hash;
with Test;

procedure Init is

  use type Ada.Containers.Count_Type;

  type Entity_ID_t is new Positive;

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

  function Entity_ID_Hash (Entity_ID : Entity_ID_t)
    return Ada.Containers.Hash_Type is
  begin
    return Ada.Containers.Hash_Type (Entity_ID);
  end Entity_ID_Hash;

  package Entity_Sets is new Ada.Containers.Hashed_Sets
    (Element_Type        => Entity_ID_t,
     Hash                => Entity_ID_Hash,
     Equivalent_Elements => "=");

  package Spatial_Hashing is new Standard.Spatial_Hash
    (Real_Type      => Float,
     Entity_ID_Type => Entity_ID_t,
     Entity_Sets    => Entity_Sets,
     Bounding_Box   => Bounding_Box);

  Spatial_Hash : Spatial_Hashing.Spatial_Hash_t;
  Entities     : Entity_Sets.Set;

begin
  Test.Assert (Spatial_Hashing.Count_Active_Cells (Spatial_Hash) = 0);
  Test.Assert (Spatial_Hashing.Count              (Spatial_Hash) = 0);

  Spatial_Hashing.Entities_For_Cell
    (Spatial_Hash => Spatial_Hash,
     Cell_ID      => 1,
     Entities     => Entities);

  Test.Assert (Entity_Sets.Length (Entities) = 0);
end Init;
