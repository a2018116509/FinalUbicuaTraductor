namespace ApiProductor.Models
{
    using System;
    using System.ComponentModel.DataAnnotations;
    public class Traduccion
    {
        [Key]
        public string NameDevice { get; set; }
        [DataType(DataType.DateTime)]
        [Required]
        public DateTime Date { get; set; }
        [Required]
        public string Translation { get; set; }
        [Required]
        public string FromLanguage { get; set; }
        [Required]
        public string ToLanguage { get; set; }
    }
}
