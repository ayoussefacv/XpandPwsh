namespace XpandPosh.Cmdlets.GetNugetPackage{
    public interface INugetPackageAssembly{
        string Package{ get; set; }
        string Version{ get; set; }
        string DotNetFramework{ get; set; }
        string File{ get; set; }
    }
}