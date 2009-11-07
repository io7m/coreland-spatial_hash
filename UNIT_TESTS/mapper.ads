package Mapper is

  type Entity_Type_t is (Static, Dynamic);

  type Entity_t is record
    Entity_Type : Entity_Type_t;
    X           : Natural;
    Y           : Natural;
    Width       : Natural;
    Height      : Natural;
  end record;

  type Entity_ID_t is new Positive;

  Parse_Error : exception;

  procedure Run;

end Mapper;
