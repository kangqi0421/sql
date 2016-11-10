create or replace type stragg_type as object
(
  string varchar2(4000),

  static function ODCIAggregateInitialize
    ( sctx in out stragg_type )
    return number ,

  member function ODCIAggregateIterate
    ( self  in out stragg_type ,
      value in     varchar2
    ) return number ,

  member function ODCIAggregateTerminate
    ( self        in  stragg_type,
      returnvalue out varchar2,
      flags in number
    ) return number ,

  member function ODCIAggregateMerge
    ( self in out stragg_type,
      ctx2 in     stragg_type
    ) return number
);
/

create or replace type body stragg_type
is

  static function ODCIAggregateInitialize
  ( sctx in out stragg_type )
  return number
  is
  begin

    sctx := stragg_type( null ) ;

    return ODCIConst.Success ;

  end;

  member function ODCIAggregateIterate
  ( self  in out stragg_type ,
    value in     varchar2
  ) return number
  is
  begin

    self.string := self.string || ',' || value ;

    return ODCIConst.Success;

  end;

  member function ODCIAggregateTerminate
  ( self        in  stragg_type ,
    returnvalue out varchar2 ,
    flags       in  number
  ) return number
  is
  begin

    returnValue := ltrim( self.string, ',' );

    return ODCIConst.Success;

  end;

  member function ODCIAggregateMerge
  ( self in out stragg_type ,
    ctx2 in     stragg_type
  ) return number
  is
  begin

    self.string := self.string || ctx2.string;

    return ODCIConst.Success;

  end;

end;
/

create or replace function stragg
  ( input varchar2 )
  return varchar2
  deterministic
  parallel_enable
  aggregate using stragg_type
;
/