/**
 *
 */
package org.dhamma.applications.taperoom.client.models;

import java.sql.Timestamp;

import com.google.gwt.xml.client.Element;

import de.saumya.gwt.persistence.client.Repository;
import de.saumya.gwt.persistence.client.ResourceCollection;
import de.saumya.gwt.persistence.client.SingletonResource;
import de.saumya.gwt.session.client.models.Locale;
import de.saumya.gwt.session.client.models.LocaleFactory;
import de.saumya.gwt.session.client.models.User;
import de.saumya.gwt.session.client.models.UserFactory;

public class Configuration extends SingletonResource<Configuration> {
    private final UserFactory   userFactory;
    private final LocaleFactory localeFactory;

    Configuration(final Repository repository,
            final ConfigurationFactory factory, final UserFactory userFactory,
            final LocaleFactory localeFactory) {
        super(repository, factory);
        this.userFactory = userFactory;
        this.localeFactory = localeFactory;
    }

    public int                        downloadSessionIdleTimeout;
    public int                        sessionIdleTimeout;
    public int                        keepAuditLogs;
    public int                        timeToLive;
    public int                        timeToArchive;

    public String                     passwordSenderEmail;
    public String                     loginUrl;

    public ResourceCollection<Locale> locales;

    public String                     notificationSenderEmail;
    public String                     notificationRecipientEmails;

    public String                     downloadDirectory;
    public String                     tmpDownloadDirectory;
    public String                     dropboxDirectory;
    public String                     errorsDumpDirectory;
    public String                     logfilesDirectory;

    public String                     localIp;
    public String                     sendIpEmail;

    public boolean                    maintenanceMode;

    public Timestamp                  updatedAt;
    public User                       updatedBy;

    @Override
    protected void appendXml(final StringBuilder buf) {
        appendXml(buf, "session_idle_timeout", this.sessionIdleTimeout);
        appendXml(buf,
                  "download_session_idle_timeout",
                  this.downloadSessionIdleTimeout);
        appendXml(buf, "keep_audit_logs", this.keepAuditLogs);
        appendXml(buf, "password_sender_email", this.passwordSenderEmail);
        appendXml(buf, "login_url", this.loginUrl);
        appendXml(buf, "errors_dump_directory", this.errorsDumpDirectory);
        appendXml(buf, "logfiles_directory", this.logfilesDirectory);
        appendXml(buf, "time_to_live", this.timeToLive);
        appendXml(buf, "time_to_archive", this.timeToArchive);
        appendXml(buf, "locales", this.locales);
        appendXml(buf,
                  "notification_sender_email",
                  this.notificationSenderEmail);
        appendXml(buf,
                  "notification_recipient_emails",
                  this.notificationRecipientEmails);
        appendXml(buf, "local_ip", this.localIp);
        appendXml(buf, "send_ip_email", this.sendIpEmail);
        appendXml(buf, "download_directory", this.downloadDirectory);
        appendXml(buf, "tmp_download_directory", this.tmpDownloadDirectory);
        appendXml(buf, "dropbox_directory", this.dropboxDirectory);
        appendXml(buf, "maintenance_mode", this.maintenanceMode);
        appendXml(buf, "updated_at", this.updatedAt);
        appendXml(buf, "updated_by", this.updatedBy);
    }

    @Override
    protected void fromElement(final Element root) {
        this.sessionIdleTimeout = getInt(root, "session_idle_timeout");
        this.downloadSessionIdleTimeout = getInt(root,
                                                 "download_session_idle_timeout");
        this.keepAuditLogs = getInt(root, "keep_audit_logs");
        this.timeToLive = getInt(root, "time_to_live");
        this.timeToArchive = getInt(root, "time_to_archive");
        this.passwordSenderEmail = getString(root, "password_sender_email");
        this.loginUrl = getString(root, "login_url");
        this.logfilesDirectory = getString(root, "logfiles_directory");
        this.errorsDumpDirectory = getString(root, "errors_dump_directory");
        this.locales = this.localeFactory.getChildResourceCollection(root,
                                                                     "locales");
        this.notificationRecipientEmails = getString(root,
                                                     "notification_recipient_emails");
        this.notificationSenderEmail = getString(root,
                                                 "notification_sender_email");
        this.localIp = getString(root, "local_ip");
        this.sendIpEmail = getString(root, "send_ip_email");
        this.downloadDirectory = getString(root, "download_directory");
        this.tmpDownloadDirectory = getString(root, "tmp_download_directory");
        this.dropboxDirectory = getString(root, "dropbox_directory");
        this.maintenanceMode = getBoolean(root, "maintenance_mode");
        this.updatedAt = getTimestamp(root, "updated_at");
        this.updatedBy = this.userFactory.getChildResource(root, "updated_by");
    }

    @Override
    public void toString(final String indent, final StringBuilder buf) {
        toString(indent, buf, "session_idle_timeout", this.sessionIdleTimeout);
        toString(indent,
                 buf,
                 "download_session_idle_timeout",
                 this.downloadSessionIdleTimeout);
        toString(indent, buf, "keep_audit_logs", this.keepAuditLogs);
        toString(indent, buf, "time_to_live", this.timeToLive);
        toString(indent, buf, "time_to_archive", this.timeToArchive);
        toString(indent, buf, "locales", this.locales);
        toString(indent, buf, "password_sender_email", this.passwordSenderEmail);
        toString(indent, buf, "login_url", this.loginUrl);
        toString(indent, buf, "errors_dump_directory", this.errorsDumpDirectory);
        toString(indent, buf, "logfiles_directory", this.logfilesDirectory);
        toString(indent,
                 buf,
                 "notification_sender_emailn",
                 this.notificationSenderEmail);
        toString(indent,
                 buf,
                 "notification_recipient_emails",
                 this.notificationRecipientEmails);
        toString(indent, buf, "local_ip", this.localIp);
        toString(indent, buf, "send_ip_email", this.sendIpEmail);
        toString(indent, buf, "download_directory", this.downloadDirectory);
        toString(indent,
                 buf,
                 "tmp_download_directory",
                 this.tmpDownloadDirectory);
        toString(indent, buf, "dropbox_directory", this.dropboxDirectory);
        toString(indent, buf, "maintenance_mode", this.maintenanceMode);
        toString(indent, buf, "updated_at", this.updatedAt);
        toString(indent, buf, "updated_by", this.updatedBy);
    }

    @Override
    public String display() {
        return "--configuration--";
    }
}
