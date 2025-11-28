using System.Threading.Tasks;
using Statiq.App;
using Statiq.Web;
using Statiq.Images;

namespace PersonalWebsite
{
  public class Program
  {
    public static async Task<int> Main(string[] args) =>
      await Bootstrapper
        .Factory
        .CreateWeb(args)
        .BuildPipeline("ResizeImages", builder =>
            {
                builder.WithInputReadFiles("assets/images/*.{jpg,png,gif}");
                builder.WithInputModules(new MutateImage()
                    .Resize(1920, null).OutputAsWebp().And()
                    .Resize(1200, null).OutputAsWebp().And()
                    .Resize(900, null).OutputAsWebp().And()
                    .Resize(640, null).OutputAsWebp().And()
                    .Resize(1920, null).OutputAsJpeg()
                );
                builder.WithOutputWriteFiles();
            })
        .RunAsync();
  }
}