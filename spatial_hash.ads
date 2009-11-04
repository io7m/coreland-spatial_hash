with Ada.Containers.Hashed_Maps;
with Ada.Containers.Hashed_Sets;

generic
  type Real_Type is digits <>;

  type Entity_ID_Type is range <>;

  with procedure Bounding_Box
    (Entity : in     Entity_ID_Type;
     Top    :    out Real_Type'Base;
     Bottom :    out Real_Type'Base;
     Left   :    out Real_Type'Base;
     Right  :    out Real_Type'Base);

package Spatial_Hash is

  --
  -- Spatial hash structure.
  --

  type Spatial_Hash_t is limited private;

  --
  -- Abstract cell identifier.
  --

  type Cell_ID_t is range 0 .. (2 ** 31 - 1);

  --
  -- Set of entities for a given cell.
  --

  type Entity_Set_t is limited private;

  --
  -- Add a dynamic entity to the spatial hash.
  --

  procedure Add_Dynamic_Entity
    (Spatial_Hash : in out Spatial_Hash_t;
     Entity_ID    : in     Entity_ID_Type);

  --
  -- Add a static entity to the spatial hash.
  --

  procedure Add_Static_Entity
    (Spatial_Hash : in out Spatial_Hash_t;
     Entity_ID    : in     Entity_ID_Type);

  --
  -- Clear entities from spatial hash. This will only
  -- clear dynamic entities.
  --

  procedure Clear
    (Spatial_Hash : in out Spatial_Hash_t);

  --
  -- Clear entities from spatial hash. This includes
  -- static entities.
  --

  procedure Clear_All
    (Spatial_Hash : in out Spatial_Hash_t);

  --
  -- Return count of cells containing entities in spatial hash.
  --

  function Count_Active_Cells
    (Spatial_Hash : in Spatial_Hash_t) return Natural;

  --
  -- Return count of entities in spatial hash.
  --

  function Count
    (Spatial_Hash : in Spatial_Hash_t) return Natural;

  --
  -- Set cell size.
  --

  procedure Set_Cell_Size
    (Spatial_Hash : in out Spatial_Hash_t;
     Cell_Size    : in     Real_Type'Base);

private

  --
  -- As IDs are already unique, these are just type conversions.
  --

  function Entity_Hash (Entity_ID : Entity_ID_Type) return Ada.Containers.Hash_Type;

  function Cell_ID_Hash (Cell_ID : Cell_ID_t) return Ada.Containers.Hash_Type;

  --
  -- Set of entities per cell.
  --

  package Entity_Sets is new Ada.Containers.Hashed_Sets
    (Element_Type        => Entity_ID_Type,
     Hash                => Entity_Hash,
     Equivalent_Elements => "=");

  type Entity_Set_t is new Entity_Sets.Set with null record;

  package Cell_Maps is new Ada.Containers.Hashed_Maps
    (Key_Type        => Cell_ID_t,
     Element_Type    => Entity_Set_t,
     Hash            => Cell_ID_Hash,
     Equivalent_Keys => "=");

  type Cell_Map_t is new Cell_Maps.Map with null record;

  type Spatial_Hash_t is record
    Dynamic_Entities : Cell_Map_t;
    Static_Entities  : Cell_Map_t;
    Dynamic_Count    : Natural        := 0;
    Static_Count     : Natural        := 0;
    Cell_Size        : Real_Type'Base := Real_Type'Base'First;
  end record;

end Spatial_Hash;
