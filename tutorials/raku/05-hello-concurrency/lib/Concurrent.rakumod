unit module Concurrent;

sub fetch-all(@urls --> List) is export {
    return () unless @urls;

    my @promises = @urls.map: -> $url {
        start {
            sleep 0.01;
            { url => $url, status => 200 }
        }
    };

    return await @promises;
}

sub pipeline(@data, *@stages --> List) is export {
    my @current = @data;
    for @stages -> &stage {
        my @promises = @current.map: -> $item { start { stage($item) } };
        @current = await @promises;
    }
    return @current;
}
