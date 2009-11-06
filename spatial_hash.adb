package body Spatial_Hash is

  use type Ada.Containers.Count_Type;
  use type Cell_Maps.Cursor;

  --
  -- Private subprograms
  --

  type Bounding_Box_t is record
    Left   : Discrete_Axis_Value_Type'Base;
    Width  : Discrete_Axis_Value_Type'Base;
    Bottom : Discrete_Axis_Value_Type'Base;
    Height : Discrete_Axis_Value_Type'Base;
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
        if Entity_Sets.Length (Entities) > 0 then
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
       Width  => Box.Width,
       Bottom => Box.Bottom,
       Height => Box.Height);

    declare
      Leftmost  : constant Cell_t := Cell_t (Box.Left / Configuration.Cell_Size);
      Rightmost : constant Cell_t := Cell_t ((Box.Left + Box.Width) / Configuration.Cell_Size);
      Row       : Axis_Value_t := 0;
      Shift     : Cell_t       := 0;
    begin
      loop
        exit when Box.Bottom + (Row * Configuration.Cell_Size) >= Box.Bottom + Box.Height;

        Shift := Cell_t (Row) * Configuration.Cells_Wide;

        Add_Entity_In_Cell_Strip
          (Cell_Map       => Cell_Map,
           Entity_ID      => Entity_ID,
           Leftmost_Cell  => Leftmost + Shift,
           Rightmost_Cell => Rightmost + Shift);

        Row := Row + 1;
      end loop;
    end;
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
      pragma Assert (Cell >= Leftmost_Cell);
      pragma Assert (Cell <= Rightmost_Cell);
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
     Width        : in     Width_t;
     Height       : in     Height_t;
     Cell_Size    : in     Cell_Size_t) is
  begin
    Spatial_Hash.Configuration.Width      := Width;
    Spatial_Hash.Configuration.Height     := Height;
    Spatial_Hash.Configuration.Cell_Size  := Cell_Size;
    Spatial_Hash.Configuration.Cells_Wide := Cell_t (Width / Cell_Size);
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
