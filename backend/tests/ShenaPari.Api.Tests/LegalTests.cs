using System.Net;
using ShenaPari.Api.Dtos;

namespace ShenaPari.Api.Tests;

public class LegalTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    [Theory]
    [InlineData("terms", "## 1. Прийняття умов")]
    [InlineData("privacy", "## 1. Загальні положення")]
    public async Task Documents_are_served_without_signing_in(string type, string firstHeading)
    {
        var response = await api.CreateClient().GetAsync($"/legal/{type}");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var document = (await response.ReadResultAsync<LegalDocumentDto>()).Data!;
        Assert.StartsWith(firstHeading, document.Content);
        Assert.Matches("^[0-9a-f]{12}$", document.Version);
    }

    [Fact]
    public async Task The_version_is_stable_and_differs_between_documents()
    {
        var client = api.CreateClient();

        var terms1 = await client.GetDataAsync<LegalDocumentDto>("/legal/terms");
        var terms2 = await client.GetDataAsync<LegalDocumentDto>("/legal/terms");
        var privacy = await client.GetDataAsync<LegalDocumentDto>("/legal/privacy");

        Assert.Equal(terms1.Version, terms2.Version);
        Assert.NotEqual(terms1.Version, privacy.Version);
    }

    [Fact]
    public async Task An_unknown_document_is_404_with_a_code()
    {
        var response = await api.CreateClient().GetAsync("/legal/cookies");

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
        Assert.Equal(["legal.not_found"], (await response.ReadResultAsync<object>()).Errors);
    }
}
