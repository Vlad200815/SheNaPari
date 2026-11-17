namespace ShenaPari.Api.Dtos;

/// <summary>A legal document: <c>Version</c> changes with the text, <c>Content</c> is Markdown.</summary>
public record LegalDocumentDto(string Version, string Content);
