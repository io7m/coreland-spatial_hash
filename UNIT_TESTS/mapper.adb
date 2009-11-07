with Ada.Characters.Latin_1;
with Ada.Containers.Ordered_Sets;
with Ada.Containers.Vectors;
with Ada.IO_Exceptions;
with Ada.Integer_Text_IO;
with Ada.Strings.Maps;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Getline;
with Spatial_Hash;

pragma Elaborate_All (Spatial_Hash);

package body Mapper is
  package Integer_IO renames Ada.Integer_Text_IO;
  package Latin_1    renames Ada.Characters.Latin_1;
  package Maps       renames Ada.Strings.Maps;
  package Text_IO    renames Ada.Text_IO;
  package UB_Strings renames Ada.Strings.Unbounded;

  package Entity_Vectors is new Ada.Containers.Vectors
    (Element_Type => Entity_t,
     Index_Type   => Entity_ID_t);

  package Entity_Sets is new Ada.Containers.Ordered_Sets
    (Element_Type => Entity_ID_t);

  Area_Width  : Positive;
  Area_Height : Positive;
  Cell_Size   : Positive;
  Line_Buffer : UB_Strings.Unbounded_String;
  Entities    : Entity_Vectors.Vector;

  procedure Bounding_Box
    (Entity : in     Entity_ID_t;
     Bottom :    out Positive;
     Height :    out Positive;
     Left   :    out Positive;
     Width  :    out Positive);

  package Spatial_Hashing is new Standard.Spatial_Hash
    (Discrete_Axis_Value_Type => Integer,
     Entity_ID_Type           => Entity_ID_t,
     Entity_Sets              => Entity_Sets,
     Bounding_Box             => Bounding_Box);

  package Cell_Sets renames Spatial_Hashing.Cell_Sets;

  package ID_IO   is new Ada.Text_IO.Integer_IO (Entity_ID_t);
  package Type_IO is new Ada.Text_IO.Enumeration_IO (Entity_Type_t);
  package Cell_IO is new Ada.Text_IO.Integer_IO (Spatial_Hashing.Cell_t);

  Spatial_Hash : Spatial_Hashing.Spatial_Hash_t;
  Active_Cells : Spatial_Hashing.Cell_Set_t;

  --
  -- Private subprograms.
  --

  procedure Clear_Line_Buffer;

  procedure Divider;

  procedure Fill_Line_Buffer;

  procedure Init;

  procedure Init_Bounds;

  procedure Init_Entities;

  procedure Init_IO;

  procedure Init_Spatial_Hash;

  procedure Read_Integer (Value : out Integer);

  procedure Read_Type (Value : out Entity_Type_t);

  procedure Statistics;

  --
  -- Bounding_Box
  --

  procedure Bounding_Box
    (Entity : in     Entity_ID_t;
     Bottom :    out Positive;
     Height :    out Positive;
     Left   :    out Positive;
     Width  :    out Positive)
  is
    procedure Query_Entity (Entity : in Entity_t) is
    begin
      Left   := Entity.X;
      Width  := Entity.Width;
      Bottom := Entity.Y;
      Height := Entity.Height;
    end Query_Entity;
  begin
    Entity_Vectors.Query_Element
      (Container => Entities,
       Index     => Entity,
       Process   => Query_Entity'Access);
  end Bounding_Box;

  --
  -- Clear_Line_Buffer
  --

  procedure Clear_Line_Buffer is
  begin
    Line_Buffer := UB_Strings.To_Unbounded_String ("");
  end Clear_Line_Buffer;

  --
  -- Divider
  --

  procedure Divider is
  begin
    Text_IO.Put_Line ("--------------------------------------------------");
  end Divider;

  --
  -- Fill_Line_Buffer
  --

  procedure Fill_Line_Buffer is
    First_Character : Character;
  begin
    loop
      Getline.Get
        (File => Text_IO.Current_Input,
         Item => Line_Buffer);
      First_Character := UB_Strings.Element
        (Source => Line_Buffer,
         Index  => 1);

      exit when First_Character /= '#' and First_Character /= Latin_1.LF;

      Clear_Line_Buffer;
    end loop;
  end Fill_Line_Buffer;

  --
  -- Init
  --

  procedure Init is
  begin
    Init_IO;
    Init_Bounds;
    Init_Entities;
    Init_Spatial_Hash;
  end Init;

  --
  -- Init_Bounds
  --

  procedure Init_Bounds is
  begin
    Clear_Line_Buffer;
    Fill_Line_Buffer;

    Read_Integer (Area_Width);
    Read_Integer (Area_Height);
    Read_Integer (Cell_Size);

    Text_IO.Put ("area_width:  ");
    Integer_IO.Put (Area_Width);
    Text_IO.New_Line;

    Text_IO.Put ("area_height: ");
    Integer_IO.Put (Area_Height);
    Text_IO.New_Line;

    Text_IO.Put ("cell_size:   ");
    Integer_IO.Put (Cell_Size);
    Text_IO.New_Line;

    Divider;
  end Init_Bounds;

  --
  -- Init_Entities
  --

  procedure Init_Entities is
    Done      : Boolean := False;
    Entity    : Entity_t;
    Entity_ID : Entity_ID_t := Entity_ID_t'First;
  begin
    loop exit when Done;
      Clear_Line_Buffer;

      begin
        Fill_Line_Buffer;

        Read_Type    (Entity.Entity_Type);
        Read_Integer (Entity.X);
        Read_Integer (Entity.Y);
        Read_Integer (Entity.Width);
        Read_Integer (Entity.Height);

        Text_IO.Put    ("entity: ");
        ID_IO.Put      (Entity_ID);
        Text_IO.Put    (" ");
        Type_IO.Put    (Entity.Entity_Type);
        Text_IO.Put    (" ");
        Integer_IO.Put (Entity.X);
        Text_IO.Put    (" ");
        Integer_IO.Put (Entity.Y);
        Text_IO.Put    (" ");
        Integer_IO.Put (Entity.Width);
        Text_IO.Put    (" ");
        Integer_IO.Put (Entity.Height);
        Text_IO.New_Line;

        Entity_Vectors.Append (Entities, Entity);

        Entity_ID := Entity_ID + 1;
      exception
        when Ada.IO_Exceptions.End_Error => Done := True;
      end;
    end loop;

    Divider;
  end Init_Entities;

  --
  -- Init_IO
  --

  procedure Init_IO is
  begin
    ID_IO.Default_Width      := 0;
    Cell_IO.Default_Width    := 0;
    Integer_IO.Default_Width := 0;
  end Init_IO;

  --
  -- Init_Spatial_Hash
  --

  procedure Init_Spatial_Hash is
  begin
    Spatial_Hashing.Initialize
      (Spatial_Hash => Spatial_Hash,
       Width        => Area_Width,
       Height       => Area_Height,
       Cell_Size    => Cell_Size);

    for ID in Entity_ID_t'First .. Entity_Vectors.Last_Index (Entities) loop
      declare
        procedure Add_Entity_To_Hash (Entity : in Entity_t) is
        begin
          case Entity.Entity_Type is
            when Static  => Spatial_Hashing.Add_Static_Entity (Spatial_Hash, ID);
            when Dynamic => Spatial_Hashing.Add_Dynamic_Entity (Spatial_Hash, ID);
          end case;
        end Add_Entity_To_Hash;
      begin
        Text_IO.Put ("adding: ");
        ID_IO.Put (ID);
        Text_IO.New_Line;

        Entity_Vectors.Query_Element
          (Container => Entities,
           Index     => ID,
           Process   => Add_Entity_To_Hash'Access);
      end;
    end loop;

    Divider;
  end Init_Spatial_Hash;

  --
  -- Read_Integer
  --

  procedure Read_Integer
    (Value : out Integer)
  is
    Index      : Natural;
    Whitespace : constant Maps.Character_Set := Maps.To_Set (" ");
  begin
    -- Find blank.
    Index := UB_Strings.Index
      (Source => Line_Buffer,
       Set    => Whitespace,
       From   => 1);
    if Index = 0 then
      Index := UB_Strings.Length (Line_Buffer);
    end if;

    Value := Positive'Value (UB_Strings.Slice (Line_Buffer, 1, Index));

    -- Delete consumed characters.
    UB_Strings.Delete
      (Source  => Line_Buffer,
       From    => 1,
       Through => Index);

    -- Delete now leading space.
    UB_Strings.Trim
      (Source => Line_Buffer,
       Side   => Ada.Strings.Left);
  end Read_Integer;

  --
  -- Read_Type
  --

  procedure Read_Type
    (Value : out Entity_Type_t)
  is
    Index      : Natural;
    Whitespace : constant Maps.Character_Set := Maps.To_Set (" ");
  begin
    Index := UB_Strings.Index
      (Source => Line_Buffer,
       Set    => Whitespace,
       From   => 1);
    if Index = 0 then
      Index := UB_Strings.Length (Line_Buffer);
    end if;

    Value := Entity_Type_t'Value (UB_Strings.Slice (Line_Buffer, 1, Index));

    -- Delete consumed characters.
    UB_Strings.Delete
      (Source  => Line_Buffer,
       From    => 1,
       Through => Index);

    -- Delete now leading space.
    UB_Strings.Trim
      (Source => Line_Buffer,
       Side   => Ada.Strings.Left);
  end Read_Type;

  --
  -- Run
  --

  procedure Run is
  begin
    Init;
    Statistics;
  end Run;

  --
  -- Statistics
  --

  procedure Statistics is
    procedure Show_Cell (Position : in Cell_Sets.Cursor) is
    begin
      Cell_IO.Put (Cell_Sets.Element (Position));
      Text_IO.Put (" ");
    end Show_Cell;

    procedure Show_Entities_For_Cell (Position : in Cell_Sets.Cursor) is
      Cell             : constant Spatial_Hashing.Cell_t := Cell_Sets.Element (Position);
      Entities_In_Cell : Entity_Sets.Set;

      procedure Show_Entity (Position : in Entity_Sets.Cursor) is
        procedure Show (Entity : in Entity_ID_t) is
        begin
          ID_IO.Put   (Entity);
          Text_IO.Put (" ");
        end Show;
      begin
        Entity_Sets.Query_Element (Position, Show'Access);
      end Show_Entity;

    begin
      Spatial_Hashing.Entities_For_Cell
        (Spatial_Hash => Spatial_Hash,
         Cell         => Cell,
         Entities     => Entities_In_Cell);

      Text_IO.Put ("cell ");
      Cell_IO.Put (Cell);
      Text_IO.Put (" entities: ");
      Entity_Sets.Iterate (Entities_In_Cell, Show_Entity'Access);
      Text_IO.New_Line;

      Text_IO.Put    ("number of entities in cell: ");
      Integer_IO.Put (Natural (Entity_Sets.Length (Entities_In_Cell)));
      Text_IO.New_Line;
    end Show_Entities_For_Cell;

  begin
    Spatial_Hashing.Active_Cells
      (Spatial_Hash => Spatial_Hash,
       Cells        => Active_Cells);

    Text_IO.Put    ("number of cells active: ");
    Integer_IO.Put (Natural (Cell_Sets.Length (Active_Cells)));
    Text_IO.New_Line;

    Text_IO.Put ("cells: ");
    Cell_Sets.Iterate (Active_Cells, Show_Cell'Access);
    Text_IO.New_Line;

    Divider;

    Cell_Sets.Iterate (Active_Cells, Show_Entities_For_Cell'Access);
  end Statistics;

end Mapper;
