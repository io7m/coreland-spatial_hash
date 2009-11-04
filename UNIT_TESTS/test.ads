package Test is

  procedure Assert
   (Check        : in Boolean;
    Pass_Message : in String := "assertion passed";
    Fail_Message : in String := "assertion failed");

end Test;
