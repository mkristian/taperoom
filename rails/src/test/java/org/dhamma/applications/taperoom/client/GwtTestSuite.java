package org.dhamma.applications.taperoom.client;

import org.dhamma.applications.taperoom.client.models.ConfigurationTestGwt;

import junit.framework.Test;
import junit.framework.TestSuite;

import com.google.gwt.junit.tools.GWTTestSuite;

public class GwtTestSuite extends GWTTestSuite {

    public static Test suite() {
        final TestSuite suite = new TestSuite("Test for GWT Application");
        suite.addTestSuite(ConfigurationTestGwt.class);
        return suite;
    }
}
