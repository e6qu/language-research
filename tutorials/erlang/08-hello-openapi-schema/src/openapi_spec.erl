-module(openapi_spec).
-export([spec/0]).

spec() ->
    #{
        <<"openapi">> => <<"3.0.0">>,
        <<"info">> => #{<<"title">> => <<"Hello API">>, <<"version">> => <<"1.0.0">>},
        <<"paths">> => #{
            <<"/api/greet">> => #{
                <<"get">> => #{
                    <<"summary">> => <<"Get a greeting">>,
                    <<"parameters">> => [
                        #{<<"name">> => <<"name">>, <<"in">> => <<"query">>,
                          <<"required">> => true,
                          <<"schema">> => #{<<"type">> => <<"string">>}}
                    ],
                    <<"responses">> => #{
                        <<"200">> => #{
                            <<"description">> => <<"A greeting">>,
                            <<"content">> => #{
                                <<"application/json">> => #{
                                    <<"schema">> => #{
                                        <<"type">> => <<"object">>,
                                        <<"properties">> => #{
                                            <<"message">> => #{<<"type">> => <<"string">>}
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }.
