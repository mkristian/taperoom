/*
 * $Id: concat_pdf.java,v 1.8 2004/02/07 10:29:03 blowagie Exp $
 * $Name: $
 *
 * This code is free software. It may only be copied or modified
 * if you include the following copyright notice:
 *
 * This class by Mark Thompson. Copyright (c) 2002 Mark Thompson.
 *
 * This code is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * itext@lowagie.com
 */

/**
 * This class demonstrates copying a PDF file using iText.
 * @author Mark Thompson
 * @author Kristian Meier
 */
/*
 * added password and metadata stuff (Kristian)
 */
package org.pariyatti.tools;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.lowagie.text.Anchor;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.BadPdfFormatException;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PRAcroForm;
import com.lowagie.text.pdf.PdfCopy;
import com.lowagie.text.pdf.PdfDictionary;
import com.lowagie.text.pdf.PdfImportedPage;
import com.lowagie.text.pdf.PdfName;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfString;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.pdf.RandomAccessFileOrArray;
import com.lowagie.text.pdf.SimpleBookmark;

public class PdfAddPersonalFrontPage {

    static class LocaleMap extends HashMap<String, Map<String, String>>{

        private static final long serialVersionUID = 1L;

        static final String PURCHASE_ONLY_AUTHORIZED = "purchase only authorized";
        static final String SUPPORT_PARIYATTI = "support Pariyatti";
        static final String SCANNING_UPLOADING = "scanning, uploading";
        static final String BELONGS_TO = "belongs_to";

        LocaleMap() {
            Map<String, String> map = new HashMap<String, String>();
            map.put(BELONGS_TO, "This e-book belongs to ");
            map.put(SCANNING_UPLOADING, "The scanning, uploading, and distribution of this book via the Internet or by any other means without the permission of the publisher violates the copyright.");
            map.put(SUPPORT_PARIYATTI, "You support Pariyatti in its mission by honoring the copyright and by not sharing this e-book broadly with others who might otherwise purchase it. By encouraging others to purchase e-books, you will be helping Pariyatti to continue to bring future books such as this one to a broader audience.");
            map.put(PURCHASE_ONLY_AUTHORIZED, "Please purchase only authorized electronic editions and do not participate in or encourage electronic piracy of copyrighted materials. Thank you for your support.");
            put("en", map);

            map = new HashMap<String, String>();
            map.put(BELONGS_TO, "Este libro pertenece a ");
            map.put(SCANNING_UPLOADING, "El escaneo, el subir y distribución de este libro a través de Internet o por cualquier otro medio sin la autorización de la editorial viola los derechos de autor.");
            map.put(SUPPORT_PARIYATTI, "Usted apoya a Pariyatti en su misión, mediante el cumplimiento de los derechos de autor y no por compartir este e-book con otras personas, que de otro modo podrían comprarlo. Al alentar a terceros para que compren los libros electrónicos, usted estará ayudando a Pariyatti que siga aportando futuros libros como este para un público más amplio.");
            map.put(PURCHASE_ONLY_AUTHORIZED, "Por favor, compre sólo ediciones electrónicas autorizadas y no participe o aliente a la piratería electrónica de los materiales con derechos de autor. Gracias por su apoyo.");
            put("es", map);

            map = new HashMap<String, String>();
            map.put(BELONGS_TO, "Tato elektronická kniha (E-book) je majetkem ");
            map.put(SCANNING_UPLOADING, "Skenování, sdílení a distribuce této knihy prostřednictvím internetu nebo jakkoli jinak bez souhlasu vydavatele je porušením autorských práv.");
            map.put(SUPPORT_PARIYATTI, "Podpořte nakladatelství Pariyatti v jeho misi tím, že budete respektovat autorská práva a nebudete knihu sdílet s ostatními, kteří by si ji jinak koupili. Když doporučíte druhým, aby si elektronickou knihu koupili, pomůžete nakladatelství Pariyatti, aby mohlo do budoucna nabízet knihy, jako je tato, širšímu okruhu čtenářů.");
            map.put(PURCHASE_ONLY_AUTHORIZED, "Kupujte prosím pouze autorizovaná elektronická vydání a neúčastněte se ani nepodporujte elektronické piráctví s materiály chráněnými autorskými právy. Děkujeme za vaši podporu.");
            put("cz", map);
            
            map = new HashMap<String, String>();
            map.put(BELONGS_TO, "Questo libro elettronico è di proprietà di ");
            map.put(SCANNING_UPLOADING, "La scansione, il caricamento e la distribuzione di questo libro in rete o con qualsiasi altro mezzo senza l’autorizzazione dell’editore violano il diritto d’autore.");
            map.put(SUPPORT_PARIYATTI, "Attraverso il rispetto del diritto d’autore e astenendosi dal distribuire diffusamente questo libro elettronico a terzi che potrebbero altrimenti acquistarlo si sostiene Pariyatti nella sua missione. Incoraggiando altri all’acquisto di un libro elettronico, si aiuta Pariyatti a continuare a far arrivare libri come questo a un più vasto pubblico.");
            map.put(PURCHASE_ONLY_AUTHORIZED, "Vi preghiamo di acquistare esclusivamente edizioni elettroniche autorizzate e di non partecipare alla pirateria elettronica di materiale coperto da diritto d’autore né di incoraggiarla. Vi ringraziamo del vostro sostegno.");
            put("it", map);            
        }

        @Override
        public Map<String, String> get(Object locale){
            return super.get(containsKey(locale)? locale : "en");
        }
    }

    /**
     * This class can be used to concatenate existing PDF files. (This was an
     * example known as PdfCopy.java)
     *
     * @param args
     * the command line arguments
     */
    public static void main(final String args[]) {
        if (args.length < 2) {
            System.err.println("arguments: user email [pwd@]destfile [pwd@]file1");
            System.err.println(" the metadata are taken from the last file");
        }
        else {
            try {
                String outFile = args[2];
                String outPwd = null;
                if (outFile.contains("@")) {
                    final int index = outFile.lastIndexOf("@");
                    outPwd = outFile.substring(0, index);
                    outFile = outFile.substring(index + 1);
                }

                String inFile = args[3];
                String inPwd = null;
                if (inFile.contains("@")) {
                    final int index = inFile.lastIndexOf("@");
                    inPwd = inFile.substring(0, index);
                    inFile = inFile.substring(index + 1);
                }
                new PdfAddPersonalFrontPage("FreeSans.ttf").process(args[0],
                                                      args[1],
                                                      "cz",
                                                      new FileInputStream(inFile),
                                                      new FileOutputStream(outFile),
                                                      inPwd,
                                                      outPwd);
            }
            catch (final Exception e) {
                e.printStackTrace();
            }
        }
    }

    private final String fontFile;
    
    PdfAddPersonalFrontPage(){
        this(null);
    }

    PdfAddPersonalFrontPage(String fontFile){
        this.fontFile= fontFile;
    }
    
    @SuppressWarnings("unchecked")
    void process(final String name, final String email, final String locale, final InputStream in,
                 final OutputStream out, final String inPwd, final String outPwd)
        throws DocumentException, IOException {

        // step 1: creation of a document-object
        final Document document = new Document();// reader.getPageSizeWithRotation(1));
        // step 2: we create a writer that listens to the
        // document
        final PdfCopy writer = new PdfCopy(document, out);
        // write out permissions when the password is given
        writer.setEncryption(null,
                             outPwd == null ? null : outPwd.getBytes(),
                             PdfWriter.AllowScreenReaders,
                             true);
        // step 3: we open the document
        document.open();

        // step 4: we add content
        // copyPages(reader, writer, 1);

        final PdfReader reader = inPwd == null
            ? new PdfReader(in)
            : new PdfReader(in, inPwd.getBytes());

        reader.consolidateNamedDestinations();
        final Map info = reader.getInfo();
        // System.out.println(reader.getInfo());

        // we retrieve the total number of pages
        final int n = reader.getNumberOfPages();
        final List<String> bookmarks = SimpleBookmark.getBookmark(reader);
        if (bookmarks != null) {
            SimpleBookmark.shiftPageNumbers(bookmarks, 1, null);
        }
        // System.out.println("There are " + n + " pages");

        final PdfDictionary dict = writer.getInfo();
        for (final Object key : info.keySet()) {
            if (!"ProducerModDate".contains(key.toString())) {
                dict.put(new PdfName(key.toString()),
                         new PdfString(info.get(key).toString(), PdfString.TEXT_UNICODE));
            }
        }
        final PdfReader readerPersonal = new PdfReader(firstPage(name,
                                                                 email,
                                                                 locale,
                                                                 reader.getPageSizeWithRotation(2)));

        copyPages(reader, writer, 1, 0);
        copyPages(readerPersonal, writer, 1, 0);
        copyPages(reader, writer, n - 1, 1);

        if (bookmarks != null && bookmarks.size() > 0) {
            writer.setOutlines(bookmarks);
        }
        // step 5: we close the document
        document.close();
    }

    private void copyPages(final PdfReader reader, final PdfCopy writer,
                           final int n, final int offset) throws IOException,
                                                                 BadPdfFormatException {
        PdfImportedPage page;
        for (int i = offset; i < offset + n;) {
            ++i;
            page = writer.getImportedPage(reader, i);
            writer.addPage(page);
            // System.out.println("Processed page " + i);
        }
        final PRAcroForm form = reader.getAcroForm();
        if (form != null) {
            writer.copyAcroForm(reader);
        }
    }

    private void add(Paragraph parent, Paragraph child){
        parent.add(child);
        parent.add(new Paragraph(" "));
    }

    private byte[] firstPage(final String name, final String email, final String locale,
                             final Rectangle pagesize) throws DocumentException, IOException {
        final Map<String, String> translations = new LocaleMap().get(locale);
        final Document document = new Document(pagesize);
        final ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        PdfWriter.getInstance(document, bytes);
        document.open();
        final Paragraph page = new Paragraph();
        BaseFont fnt = BaseFont.createFont(fontFile == null? BaseFont.HELVETICA : fontFile,
                    BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
        
        final Font fontLink = new Font(fnt, 10);
        //fontLink.setStyle(Font.BOLD);
        fontLink.setColor(Color.BLUE);
        final Anchor anchor = new Anchor(name + " <" + email + ">", fontLink);
        // no active link !!!
        // anchor.setReference("mailto: " + email);
        final Font font = new Font(fnt, 10);
        //font.setStyle(Font.BOLD);
        Paragraph paragraph = new Paragraph(200,
                                            translations.get(LocaleMap.BELONGS_TO),
                                            font);
        paragraph.add(anchor);
        paragraph.setAlignment(Element.ALIGN_LEFT);
        add(page, paragraph);

        paragraph = new Paragraph(200,
                                  translations.get(LocaleMap.SCANNING_UPLOADING),
                                  font);
        paragraph.setAlignment(Element.ALIGN_LEFT);
        add(page, paragraph);

        paragraph = new Paragraph(200,
                                  translations.get(LocaleMap.SUPPORT_PARIYATTI),
                                  font);
        paragraph.setAlignment(Element.ALIGN_LEFT);
        add(page, paragraph);

        paragraph = new Paragraph(200,
                                  translations.get(LocaleMap.PURCHASE_ONLY_AUTHORIZED),
                                  font);
        paragraph.setAlignment(Element.ALIGN_LEFT);
        add(page, paragraph);

        document.add(page);

        document.close();
        try {
            bytes.close();
        }
        catch (final IOException e) {
            // ignore it
        }
        return bytes.toByteArray();
    }
}