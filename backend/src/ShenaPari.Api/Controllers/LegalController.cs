using Microsoft.AspNetCore.Mvc;
using ShenaPari.Api.Common;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Legal;

namespace ShenaPari.Api.Controllers;

// No [Authorize]: the documents are linked from the sign-in screen.
[ApiController]
[Route("legal")]
public class LegalController : ControllerBase
{
    // GET /legal/terms, /legal/privacy, /legal/refund — { version, content (Markdown) }
    [HttpGet("{type}")]
    public ActionResult<Result<LegalDocumentDto>> Get(string type)
    {
        Result<LegalDocumentDto> result = LegalDocuments.Find(type) is { } document
            ? document
            : LegalErrors.NotFound;
        return result.ToActionResult();
    }
}
