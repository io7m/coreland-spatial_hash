package body Spatial_Hash is

  use type Ada.Containers.Count_Type;
  use type Cell_Maps.Cursor;

  --
  -- Private subprograms
  --

  type Bounding_Box_t is record
    Left   : Discrete_Axis_Value_Type'Base;
    Right  : Discrete_Axis_Value_Type'Base;
    Top    : Discrete_Axis_Value_Type'Base;
    Bottom : Discrete_Axis_Value_Type'Base;
  end record;

  procedure Add_Entity
    (Cell_Map      : in out Cell_Map_t;
     Entity_ID     : in     Entity_ID_Type;
     Configuration : in     Configuration_t);

  procedure Add_Entity_In_Cell_Strip
    (Cell_Map       : in out Cell_Map_t;
     Entity_ID      : in     Entity_ID_Type;
     Leftmost_Cell  : in     Cell_t;
     Rightmost_Cell : in     Cell_t);

  procedure Check_Initialized (Spatial_Hash : in Spatial_Hash_t);
  pragma Inline (Check_Initialized);

  function Cell_For_Point
    (X          : in Discrete_Axis_Value_Type'Base;
     Y          : in Discrete_Axis_Value_Type'Base;
     Cell_Size  : in Long_Integer;
     Cells_Wide : in Long_Integer) return Cell_t;

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
    Check_Initialized (Spatial_Hash);

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
    Check_Initialized (Spatial_Hash);

    Add_Entity
      (Cell_Map      => Spatial_Hash.Dynamic_Entities,
       Entity_ID     => Entity_ID,
       Configuration => Spatial_Hash.Configuration);
    Spatial_Hash.Dynamic_Count := Spatial_Hash.Dynamic_Count + 1;
  end Add_Dynamic_Entity;

  --
  -- Add_Entity
  --

  procedure Add_Entity
    (Cell_Map      : in out Cell_Map_t;
     Entity_ID     : in     Entity_ID_Type;
     Configuration : in     Configuration_t)
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
  -- Add_Entity_In_Cell_Strip
  --

  procedure Add_Entity_In_Cell_Strip
    (Cell_Map       : in out Cell_Map_t;
     Entity_ID      : in     Entity_ID_Type;
     Leftmost_Cell  : in     Cell_t;
     Rightmost_Cell : in     Cell_t)
  is
    -- Insert entity into set for given cell.
    procedure Entity_Insert
      (Cell       : in     Cell_t;
       Entity_Set : in out Entity_Set_t) is
    begin
      Entity_Sets.Insert
        (Container => Entity_Set,
         New_Item  => Entity_ID);
    end Entity_Insert;

    Position : Cell_Maps.Cursor;
  begin
    for Cell in Leftmost_Cell .. Rightmost_Cell loop
      -- Create new entity set for cell, if necessary.
      if Cell_Maps.Contains (Cell_Map, Cell) = False then
        Cell_Maps.Insert
          (Container => Cell_Map,
           Key       => Cell,
           New_Item  => Entity_Sets.Empty_Set);
      end if;

      -- Locate entity set for cell.
      Position := Cell_Maps.Find (Cell_Map, Cell);

      -- Update entity set with entity ID.
      Cell_Maps.Update_Element (Cell_Map, Position, Entity_Insert'Access);
    end loop;
  end Add_Entity_In_Cell_Strip;

  --
  -- Add_Static_Entity
  --

  procedure Add_Static_Entity
    (Spatial_Hash : in out Spatial_Hash_t;
     Entity_ID    : in     Entity_ID_Type) is
  begin
    Check_Initialized (Spatial_Hash);

    Add_Entity
      (Cell_Map      => Spatial_Hash.Static_Entities,
       Entity_ID     => Entity_ID,
       Configuration => Spatial_Hash.Configuration);
    Spatial_Hash.Static_Count := Spatial_Hash.Static_Count + 1;
  end Add_Static_Entity;

  --
  -- Cell_For_Point
  --

  function Cell_For_Point
    (X          : in Discrete_Axis_Value_Type'Base;
     Y          : in Discrete_Axis_Value_Type'Base;
     Cell_Size  : in Long_Integer;
     Cells_Wide : in Long_Integer) return Cell_t
  is
    Current_X : constant Long_Integer := Long_Integer (X / Discrete_Axis_Value_Type'Base (Cell_Size));
    Current_Y : constant Long_Integer := Long_Integer (Y / Discrete_Axis_Value_Type'Base (Cell_Size));
  begin
    return Cell_t ((Current_Y * Cells_Wide) + Current_X);
  end Cell_For_Point;

  --
  -- Cell_Hash
  --

  function Cell_Hash
    (Cell : Cell_t) return Ada.Containers.Hash_Type is
  begin
    return Ada.Containers.Hash_Type (Cell);
  end Cell_Hash;

  --
  -- Check_Initialized
  --

  procedure Check_Initialized
    (Spatial_Hash : in Spatial_Hash_t) is
  begin
    if Is_Initialized (Spatial_Hash) = False then
      raise Constraint_Error with "spatial hash not initialized";
    end if;
  end Check_Initialized;

  --
  -- Clear
  --

  procedure Clear
    (Spatial_Hash : in out Spatial_Hash_t) is
  begin
    Check_Initialized (Spatial_Hash);

    Cell_Maps.Clear (Spatial_Hash.Dynamic_Entities);
    Spatial_Hash.Dynamic_Count := 0;
  end Clear;

  --
  -- Clear_All
  --

  procedure Clear_All
    (Spatial_Hash : in out Spatial_Hash_t) is
  begin
    Check_Initialized (Spatial_Hash);

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
    Check_Initialized (Spatial_Hash);

    return Spatial_Hash.Dynamic_Count + Spatial_Hash.Static_Count;
  end Count;

  --
  -- Count_Active_Cells
  --

  function Count_Active_Cells
    (Spatial_Hash : in Spatial_Hash_t) return Natural is
  begin
    Check_Initialized (Spatial_Hash);

    return Natural
      (Cell_Maps.Length (Spatial_Hash.Dynamic_Entities) +
       Cell_Maps.Length (Spatial_Hash.Static_Entities));
  end Count_Active_Cells;

  --
  -- Entities_For_Cell
  --

  procedure Entities_For_Cell
    (Spatial_Hash : in     Spatial_Hash_t;
     Cell         : in     Cell_t;
     Entities     :    out Entity_Set_t)
  is
    Position : Cell_Maps.Cursor;

    procedure Query_Cell
      (Cell    : in Cell_t;
       In_Cell : in Entity_Set_t) is
    begin
      pragma Assert (Cell = Entities_For_Cell.Cell);

      Entity_Sets.Union
        (Target => Entities,
         Source => In_Cell);
    end Query_Cell;
  begin
    Check_Initialized (Spatial_Hash);

    Entity_Sets.Clear (Entities);

    Position := Cell_Maps.Find
      (Container => Spatial_Hash.Dynamic_Entities,
       Key       => Cell);
    if Position /= Cell_Maps.No_Element then
      Cell_Maps.Query_Element (Position, Query_Cell'Access);
    end if;

    Position := Cell_Maps.Find
      (Container => Spatial_Hash.Static_Entities,
       Key       => Cell);
    if Position /= Cell_Maps.No_Element then
      Cell_Maps.Query_Element (Position, Query_Cell'Access);
    end if;
  end Entities_For_Cell;

  --
  -- Initialize
  --

  procedure Initialize
    (Spatial_Hash :    out Spatial_Hash_t;
     Width        : in     Natural;
     Height       : in     Natural;
     Cell_Size    : in     Natural) is
  begin
    Spatial_Hash.Configuration.Width      := Width;
    Spatial_Hash.Configuration.Height     := Height;
    Spatial_Hash.Configuration.Cell_Size  := Cell_Size;
    Spatial_Hash.Configuration.Cells_Wide := Width / Cell_Size;
    Spatial_Hash.Configuration.Configured := True;
  end Initialize;

  --
  -- Is_Initialized
  --

  function Is_Initialized (Spatial_Hash : in Spatial_Hash_t) return Boolean is
  begin
    return Spatial_Hash.Configuration.Configured;
  end Is_Initialized;

end Spatial_Hash;
