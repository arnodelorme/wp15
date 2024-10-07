function struct_level = create_levelParameters(TR, name, onset, duration)
    struct_level.timing_units = 'secs';
    struct_level.timing_RT = TR;
    struct_level.conditionName = name;
    struct_level.conditionOnset = onset;
    struct_level.conditionDuration = duration;
end