with Ada.Containers.Ordered_Sets;
with Spatial_Hash;

pragma Elaborate_All (Spatial_Hash);

package Data is

  use type Ada.Containers.Count_Type;

  type Entity_ID_t is new Positive;

  procedure Bounding_Box
    (Entity : in     Entity_ID_t;
     Bottom :    out Integer;
     Height :    out Integer;
     Left   :    out Integer;
     Width  :    out Integer);

  package Entity_Sets is new Ada.Containers.Ordered_Sets
    (Element_Type => Entity_ID_t);

  package Spatial_Hashing is new Standard.Spatial_Hash
    (Discrete_Axis_Value_Type => Integer,
     Entity_ID_Type           => Entity_ID_t,
     Entity_Sets              => Entity_Sets,
     Bounding_Box             => Bounding_Box);

  Spatial_Hash : Spatial_Hashing.Spatial_Hash_t;
  Active_Cells : Spatial_Hashing.Cell_Set_t;
  Entities     : Entity_Sets.Set;

end Data;
