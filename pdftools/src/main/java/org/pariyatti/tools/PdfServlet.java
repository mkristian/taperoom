package org.pariyatti.tools;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.lowagie.text.DocumentException;

public class PdfServlet extends HttpServlet {

    private static final String           X_PARIYATTI          = "x-pariyatti-";
    private static final String           X_PARIYATTI_PASSWORD = X_PARIYATTI
                                                                       + "password";
    private static final String           X_PARIYATTI_NAME     = X_PARIYATTI
                                                                       + "name";
    private static final String           X_PARIYATTI_EMAIL    = X_PARIYATTI
                                                                       + "email";
    private static final String           X_PARIYATTI_LOCALE   = X_PARIYATTI
                                                                       + "locale";

    private static final long             serialVersionUID     = 1L;

    private final PdfAddPersonalFrontPage pdf                  = new PdfAddPersonalFrontPage("FreeSans.ttf");

    @Override
    protected void doPost(final HttpServletRequest req,
            final HttpServletResponse resp) throws ServletException,
            IOException {
        final String pwd = req.getHeader(X_PARIYATTI_PASSWORD);
        final String name = req.getHeader(X_PARIYATTI_NAME);
        final String email = req.getHeader(X_PARIYATTI_EMAIL);
        final String locale = req.getHeader(X_PARIYATTI_LOCALE) == null ? "en" : req.getHeader(X_PARIYATTI_LOCALE);
        log("process pdf (length:" + req.getContentLength() + ") for " + name
                + " <" + email + ">" + " locale: " + locale);
        try {
            this.pdf.process(name,
                             email,
                             locale,
                             req.getInputStream(),
                             resp.getOutputStream(),
                             pwd,
                             pwd);
        }
        catch (final DocumentException e) {
            throw new ServletException("error processing page for " + name
                    + " <" + email + ">", e);
        }
    }
}
