package body Spatial_Hash is

  use type Ada.Containers.Count_Type;
  use type Cell_Maps.Cursor;

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
  -- Active_Cells
  --

  procedure Active_Cells
    (Spatial_Hash : in     Spatial_Hash_t;
     Cells        :    out Cell_Set_t)
  is
    procedure Process_Cursor (Position : in Cell_Maps.Cursor) is
      procedure Process_Cell
        (Cell_ID  : in Cell_t;
         Entities : in Entity_Set_t) is
      begin
        if Entity_Sets.Length (Entities) > 1 then
          Cell_Sets.Insert (Cells, Cell_ID);
        end if;
      end Process_Cell;
    begin
      Cell_Maps.Query_Element (Position, Process_Cell'Access);
    end Process_Cursor;
  begin
    Cell_Sets.Clear (Cells);
    Cell_Maps.Iterate (Spatial_Hash.Dynamic_Entities, Process_Cursor'Access);
    Cell_Maps.Iterate (Spatial_Hash.Static_Entities, Process_Cursor'Access);
  end Active_Cells;

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
    Cell_Maps.Clear (Spatial_Hash.Dynamic_Entities);
    Spatial_Hash.Dynamic_Count := 0;
  end Clear;

  --
  -- Clear_All
  --

  procedure Clear_All
    (Spatial_Hash : in out Spatial_Hash_t) is
  begin
    Clear (Spatial_Hash);
    Cell_Maps.Clear (Spatial_Hash.Static_Entities);
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
    return Natural (Cell_Maps.Length (Spatial_Hash.Dynamic_Entities) +
                    Cell_Maps.Length (Spatial_Hash.Static_Entities));
  end Count_Active_Cells;

  --
  -- Entities_For_Cell
  --

  procedure Entities_For_Cell
    (Spatial_Hash : in     Spatial_Hash_t;
     Cell_ID      : in     Cell_ID_t;
     Entities     :    out Entity_Set_t)
  is
    Position : Cell_Maps.Cursor;

    procedure Query_Cell
      (Cell_ID : in Cell_ID_t;
       In_Cell : in Entity_Set_t) is
    begin
      pragma Assert (Cell_ID = Entities_For_Cell.Cell_ID);

      Entity_Sets.Union
        (Target => Entities,
         Source => In_Cell);
    end Query_Cell;
  begin
    Entity_Sets.Clear (Entities);

    Position := Cell_Maps.Find
      (Container => Spatial_Hash.Dynamic_Entities,
       Key       => Cell_ID);
    if Position /= Cell_Maps.No_Element then
      Cell_Maps.Query_Element (Position, Query_Cell'Access);
    end if;

    Position := Cell_Maps.Find
      (Container => Spatial_Hash.Static_Entities,
       Key       => Cell_ID);
    if Position /= Cell_Maps.No_Element then
      Cell_Maps.Query_Element (Position, Query_Cell'Access);
    end if;
  end Entities_For_Cell;

  --
  -- Set_Cell_Size
  --

  procedure Set_Cell_Size
    (Spatial_Hash : in out Spatial_Hash_t;
     Cell_Size    : in     Real_Type'Base) is
  begin
    if Count (Spatial_Hash) > 0 then
      raise Constraint_Error with "spatial hash not empty";
    end if;

    Spatial_Hash.Cell_Size := Cell_Size;
  end Set_Cell_Size;

end Spatial_Hash;
