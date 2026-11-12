namespace ShenaPari.Api.Dtos;

/// Times are local campus time, "HH:mm".
public record BellBreakDto(TimeOnly Start, TimeOnly End);

public record BellScheduleDto(int Id, string Name, bool IsActive, List<BellBreakDto> Breaks);

public record CreateScheduleDto(string Name, List<BellBreakDto> Breaks);
