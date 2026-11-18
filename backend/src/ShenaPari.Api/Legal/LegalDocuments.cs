using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using ShenaPari.Api.Dtos;

namespace ShenaPari.Api.Legal;

/// <summary>
/// Terms of use, privacy policy and refund terms. The texts are Markdown files embedded in
/// the assembly (Legal/*.md); the version is a hash of the text, so it changes
/// by itself whenever the text does and the app knows to refresh its cache.
/// </summary>
public static class LegalDocuments
{
    public const string Terms = "terms";
    public const string Privacy = "privacy";
    public const string Refund = "refund";

    private static readonly Dictionary<string, LegalDocumentDto> Documents = new()
    {
        [Terms] = Load("terms.md"),
        [Privacy] = Load("privacy.md"),
        [Refund] = Load("refund.md"),
    };

    public static LegalDocumentDto? Find(string type) => Documents.GetValueOrDefault(type);

    private static LegalDocumentDto Load(string fileName)
    {
        var assembly = Assembly.GetExecutingAssembly();
        var resource = assembly.GetManifestResourceNames().Single(n => n.EndsWith($".Legal.{fileName}"));
        using var stream = assembly.GetManifestResourceStream(resource)!;
        using var reader = new StreamReader(stream, Encoding.UTF8);
        var content = reader.ReadToEnd();

        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(content));
        return new LegalDocumentDto(Convert.ToHexStringLower(hash)[..12], content);
    }
}
