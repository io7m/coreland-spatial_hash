with Ada.Containers.Hashed_Maps;
with Ada.Containers.Ordered_Sets;

generic
  type Discrete_Axis_Value_Type is range <>;

  type Entity_ID_Type is range <>;

  with package Entity_Sets is new Ada.Containers.Ordered_Sets
    (Element_Type => Entity_ID_Type);

  with procedure Bounding_Box
    (Entity : in     Entity_ID_Type;
     Bottom :    out Discrete_Axis_Value_Type'Base;
     Height :    out Discrete_Axis_Value_Type'Base;
     Left   :    out Discrete_Axis_Value_Type'Base;
     Width  :    out Discrete_Axis_Value_Type'Base);

package Spatial_Hash is

  --
  -- Spatial hash structure.
  --

  type Spatial_Hash_t is limited private;

  --
  -- Abstract cell identifier.
  --

  type Cell_t is range 0 .. (2 ** 31 - 1);

  --
  -- Ordered set of cells for queries.
  --

  package Cell_Sets  is new Ada.Containers.Ordered_Sets (Cell_t);
  subtype Cell_Set_t is Cell_Sets.Set;

  --
  -- Set of entities for a given cell.
  --

  subtype Entity_Set_t is Entity_Sets.Set;

  --
  -- Return ordered set of active cells.
  --

  procedure Active_Cells
    (Spatial_Hash : in     Spatial_Hash_t;
     Cells        :    out Cell_Set_t);
  -- pragma Precondition (Is_Initialized (Spatial_Hash));

  --
  -- Add a dynamic entity to the spatial hash.
  --

  procedure Add_Dynamic_Entity
    (Spatial_Hash : in out Spatial_Hash_t;
     Entity_ID    : in     Entity_ID_Type);
  -- pragma Precondition (Is_Initialized (Spatial_Hash));

  --
  -- Add a static entity to the spatial hash.
  --

  procedure Add_Static_Entity
    (Spatial_Hash : in out Spatial_Hash_t;
     Entity_ID    : in     Entity_ID_Type);
  -- pragma Precondition (Is_Initialized (Spatial_Hash));

  --
  -- Clear entities from spatial hash. This will only
  -- clear dynamic entities.
  --

  procedure Clear
    (Spatial_Hash : in out Spatial_Hash_t);
  -- pragma Precondition (Is_Initialized (Spatial_Hash));

  --
  -- Clear entities from spatial hash. This includes
  -- static entities.
  --

  procedure Clear_All
    (Spatial_Hash : in out Spatial_Hash_t);
  -- pragma Precondition (Is_Initialized (Spatial_Hash));

  --
  -- Return count of cells containing entities in spatial hash.
  --

  function Count_Active_Cells
    (Spatial_Hash : in Spatial_Hash_t) return Natural;
  -- pragma Precondition (Is_Initialized (Spatial_Hash));

  --
  -- Return count of entities in spatial hash.
  --

  function Count
    (Spatial_Hash : in Spatial_Hash_t) return Natural;
  -- pragma Precondition (Is_Initialized (Spatial_Hash));

  --
  -- Get entities for cell.
  --

  procedure Entities_For_Cell
    (Spatial_Hash : in     Spatial_Hash_t;
     Cell         : in     Cell_t;
     Entities     :    out Entity_Set_t);
  -- pragma Precondition (Is_Initialized (Spatial_Hash));

  --
  -- Initialize space.
  --

  subtype Axis_Value_t is Discrete_Axis_Value_Type'Base;
  subtype Cell_Size_t  is Axis_Value_t range 1 .. Axis_Value_t'Last;
  subtype Height_t     is Axis_Value_t range 1 .. Axis_Value_t'Last;
  subtype Width_t      is Axis_Value_t range 1 .. Axis_Value_t'Last;

  procedure Initialize
    (Spatial_Hash :    out Spatial_Hash_t;
     Width        : in     Width_t;
     Height       : in     Height_t;
     Cell_Size    : in     Cell_Size_t);
  -- pragma Postcondition (Is_Initialized (Spatial_Hash));

  --
  -- Return True if spatial hash is initialized.
  --

  function Is_Initialized (Spatial_Hash : in Spatial_Hash_t) return Boolean;
  pragma Inline (Is_Initialized);

private

  --
  -- As a cell ID is already unique and already likely the same
  -- underlying type as Hash_Type, this is a no-op.
  --

  function Cell_Hash (Cell : in Cell_t) return Ada.Containers.Hash_Type;

  --
  -- Set of entities per cell.
  --

  package Cell_Maps is new Ada.Containers.Hashed_Maps
    (Key_Type        => Cell_t,
     Element_Type    => Entity_Set_t,
     Hash            => Cell_Hash,
     Equivalent_Keys => "=",
     "="             => Entity_Sets."=");

  subtype Cell_Map_t is Cell_Maps.Map;

  type Configuration_t is record
    Width      : Width_t     := Width_t'First;
    Height     : Height_t    := Height_t'First;
    Cell_Size  : Cell_Size_t := Cell_Size_t'First;
    Cells_Wide : Cell_t      := Cell_t'First;
    Configured : Boolean     := False;
  end record;

  type Spatial_Hash_t is record
    Dynamic_Entities : Cell_Map_t;
    Static_Entities  : Cell_Map_t;
    Dynamic_Count    : Natural := 0;
    Static_Count     : Natural := 0;
    Configuration    : Configuration_t;
  end record;

end Spatial_Hash;
