FROM odoo:19.0

WORKDIR /opt/odoo/src

# Copy source code so CI can validate the image build and runtime packaging.
COPY --chown=odoo:odoo . /opt/odoo/src
COPY --chown=odoo:odoo docker/odoo.conf /etc/odoo/odoo.conf

USER odoo

ENV PYTHONPATH=/opt/odoo/src

EXPOSE 8069 8072

CMD ["odoo", "-c", "/etc/odoo/odoo.conf"]
