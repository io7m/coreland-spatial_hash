with Ada.Containers.Ordered_Sets;
with Spatial_Hash;

pragma Elaborate_All (Spatial_Hash);

package Data is

  use type Ada.Containers.Count_Type;

  type Entity_ID_t is new Positive;

  procedure Bounding_Box
    (Entity_ID : in     Entity_ID_t;
     Top       :    out Float;
     Bottom    :    out Float;
     Left      :    out Float;
     Right     :    out Float);

  package Entity_Sets is new Ada.Containers.Ordered_Sets
    (Element_Type => Entity_ID_t);

  package Spatial_Hashing is new Standard.Spatial_Hash
    (Real_Type      => Float,
     Entity_ID_Type => Entity_ID_t,
     Entity_Sets    => Entity_Sets,
     Bounding_Box   => Bounding_Box);

  Spatial_Hash : Spatial_Hashing.Spatial_Hash_t;
  Active_Cells : Spatial_Hashing.Cell_Set_t;
  Entities     : Entity_Sets.Set;

end Data;
