package body Spatial_Hash is

  use type Ada.Containers.Count_Type;

  --
  -- Private subprograms
  --

  type Bounding_Box_t is record
    Left   : Real_Type'Base;
    Right  : Real_Type'Base;
    Top    : Real_Type'Base;
    Bottom : Real_Type'Base;
  end record;

  procedure Add_Entity
    (Cell_Map  : in out Cell_Map_t;
     Entity_ID : in     Entity_ID_Type);

  --
  -- Add_Dynamic_Entity
  --

  procedure Add_Dynamic_Entity
    (Spatial_Hash : in out Spatial_Hash_t;
     Entity_ID    : in     Entity_ID_Type) is
  begin
    Add_Entity
      (Cell_Map  => Spatial_Hash.Dynamic_Entities,
       Entity_ID => Entity_ID);
    Spatial_Hash.Dynamic_Count := Spatial_Hash.Dynamic_Count + 1;
  end Add_Dynamic_Entity;

  --
  -- Add_Entity
  --

  procedure Add_Entity
    (Cell_Map  : in out Cell_Map_t;
     Entity_ID : in     Entity_ID_Type)
  is
    Box : Bounding_Box_t;
  begin
    Bounding_Box
      (Entity => Entity_ID,
       Left   => Box.Left,
       Right  => Box.Right,
       Top    => Box.Top,
       Bottom => Box.Bottom);
  end Add_Entity;

  --
  -- Add_Static_Entity
  --

  procedure Add_Static_Entity
    (Spatial_Hash : in out Spatial_Hash_t;
     Entity_ID    : in     Entity_ID_Type) is
  begin
    Add_Entity
      (Cell_Map  => Spatial_Hash.Static_Entities,
       Entity_ID => Entity_ID);
    Spatial_Hash.Static_Count := Spatial_Hash.Static_Count + 1;
  end Add_Static_Entity;

  --
  -- Cell_ID_Hash
  --

  function Cell_ID_Hash
    (Cell_ID : Cell_ID_t) return Ada.Containers.Hash_Type is
  begin
    return Ada.Containers.Hash_Type (Cell_ID);
  end Cell_ID_Hash;

  --
  -- Clear
  --

  procedure Clear
    (Spatial_Hash : in out Spatial_Hash_t) is
  begin
    Clear (Spatial_Hash.Dynamic_Entities);
    Spatial_Hash.Dynamic_Count := 0;
  end Clear;

  --
  -- Clear_All
  --

  procedure Clear_All
    (Spatial_Hash : in out Spatial_Hash_t) is
  begin
    Clear (Spatial_Hash);
    Clear (Spatial_Hash.Static_Entities);
    Spatial_Hash.Static_Count := 0;
  end Clear_All;

  --
  -- Count
  --

  function Count
    (Spatial_Hash : in Spatial_Hash_t) return Natural is
  begin
    return Spatial_Hash.Dynamic_Count + Spatial_Hash.Static_Count;
  end Count;

  --
  -- Count_Active_Cells
  --

  function Count_Active_Cells
    (Spatial_Hash : in Spatial_Hash_t) return Natural is
  begin
    return Natural (Length (Spatial_Hash.Dynamic_Entities) +
                    Length (Spatial_Hash.Static_Entities));
  end Count_Active_Cells;

  --
  -- Entity_Hash
  --

  function Entity_Hash
    (Entity_ID : Entity_ID_Type) return Ada.Containers.Hash_Type is
  begin
    return Ada.Containers.Hash_Type (Entity_ID);
  end Entity_Hash;

  --
  -- Set_Cell_Size
  --

  procedure Set_Cell_Size
    (Spatial_Hash : in out Spatial_Hash_t;
     Cell_Size    : in     Real_Type) is
  begin
    if Count (Spatial_Hash) > 0 then
      raise Constraint_Error with "spatial hash not empty";
    end if;

    Spatial_Hash.Cell_Size := Cell_Size;
  end Set_Cell_Size;

end Spatial_Hash;
