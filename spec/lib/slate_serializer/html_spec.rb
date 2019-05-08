require 'spec_helper'

RSpec.describe SlateSerializer::Html do
  context 'with html' do
    html = %(
    <p><strong>6.2.3.1</strong>
    Description of the issue</p><p>Decision-making
    processes and structures conducive to social responsibility are those that
    promote the practical use of the principles and practices described in Clauses
    4 and 5.&nbsp;<a href="http://wetten.overheid.nl/BWBR0023864/2018-01-01/0/Hoofdstuk3a/Artikel15b/informatie">overzicht van wijzigingen</a></p><ul>
    <li>promote fair representation of
    under-represented groups including women and racial and ethnic groups in
    senior positions in the organization;</li></ul>
    <p><strong>6.2.3.<em>1</em></strong></p>
    )

    describe '.deserializer' do
      it 'converts the html into raw' do
        raw = described_class.deserializer(html)

        expect(raw[:document][:nodes].length).to be 4
        expect(raw[:document][:nodes][0][:type]).to eq 'paragraph'
        expect(raw[:document][:nodes][1][:type]).to eq 'paragraph'
        expect(raw[:document][:nodes][2][:type]).to eq 'unordered-list'
        expect(raw[:document][:nodes][3][:type]).to eq 'paragraph'

        expect(raw[:document][:nodes][2][:nodes].length).to be 1
        expect(raw[:document][:nodes][2][:nodes][0][:type]).to eq 'list-item'

        expect(raw[:document][:nodes][3][:type]).to eq 'paragraph'
        expect(raw[:document][:nodes][3][:nodes].length).to be 1
        expect(raw[:document][:nodes][3][:nodes][0][:object]).to eq 'text'
        expect(raw[:document][:nodes][3][:nodes][0][:leaves].length).to be 2
        expect(raw[:document][:nodes][3][:nodes][0][:leaves][0][:marks][0][:type]).to eq 'bold'
      end
    end
  end

  context 'with some other html' do
    html = %(
<ol>
    <li>Deze verordening is van toepassing op de geheel of gedeeltelijk geautomatiseerde verwerking, alsmede op de&nbsp;verwerking van persoonsgegevens die in een bestand zijn opgenomen of die bestemd zijn om daarin te worden&nbsp;opgenomen.</li>
    <li>Deze verordening is niet van toepassing op de verwerking van persoonsgegevens:
        <ol type="a">
            <li>in het kader van activiteiten die buiten de werkingssfeer van het Unierecht vallen.</li>
            <li>door de lidstaten bij de uitvoering van activiteiten die binnen de werkingssfeer van titel V, hoofdstuk 2, VEU vallen.</li>
            <li>door een natuurlijke persoon bij de uitoefening van een zuiver persoonlijke of huishoudelijke activiteit.</li>
            <li>door de bevoegde autoriteiten met het oog op de voorkoming, het onderzoek, de opsporing en de vervolging van&nbsp;strafbare feiten of de tenuitvoerlegging van straffen, met inbegrip van de bescherming tegen en de voorkoming van&nbsp;gevaren
                voor de openbare veiligheid.</li>
        </ol>
    </li>
    <li>Op de verwerking van persoonsgegevens door de instellingen, organen en instanties van de Unie is Verordening&nbsp;(EG) nr. 45/2001 van toepassing. Verordening (EG) nr. 45/2001 en andere rechtshandelingen van de Unie die van&nbsp;toepassing zijn op
        een dergelijke verwerking van persoonsgegevens worden overeenkomstig artikel 98 aan de beginselen&nbsp;en regels van de onderhavige verordening aangepast.</li>
    <li>Deze verordening laat de toepassing van Richtlijn 2000/31/EG, en met name van de regels in de artikelen 12 tot&nbsp;en met 15 van die richtlijn betreffende de aansprakelijkheid van als tussenpersoon optredende dienstverleners onverlet.</li>
</ol>
    )

    describe '.deserializer' do
      it 'converts the html into raw' do
        raw = described_class.deserializer(html)

        expect(raw[:document][:nodes].length).to be 1
        expect(raw[:document][:nodes][0][:type]).to eq 'ordered-list'
        expect(raw[:document][:nodes][0][:nodes].length).to be 4
        expect(raw[:document][:nodes][0][:nodes][1][:nodes].length).to be 2
        expect(raw[:document][:nodes][0][:nodes][1][:nodes][0][:object]).to eq 'text'
        expect(raw[:document][:nodes][0][:nodes][1][:nodes][1][:type]).to eq 'alpha-ordered-list'
      end
    end
  end

  context 'with an html table' do
    html = %(
    <p>Uitgangspunt voor de VIPP-assessments is dat in opdracht van het ziekenhuis, een IT-auditor (Register EDP-auditor, RE) als onafhankelijke deskundige beoordeelt of het betreffende ziekenhuis heeft voldaan aan de doelstellingen van het VIPP-programma en hierover rapporteert aan het ziekenhuis. Het ziekenhuis zal de IT-audit rapportage verstrekken aan VWS voor de aanvraag/ verkrijging van de VIPP-subsidie dat VWS specifiek voor het VIPP-programma heeft gereserveerd. Ziekenhuizen kunnen daarbij kiezen voor welke onderdelen van het VIPP-programma en voor welke modules daarvan zij subsidie willen aanvragen.&nbsp;</p>
    <p>Daarbij wordt onderscheid gemaakt in de volgende VIPP-assessments:&nbsp;</p><table><tbody><tr><td><strong>Programma</strong></td><td><strong>VIPP-Assessment</strong></td><td><strong>Tijdslijn</strong></td></tr><tr><td>Patiënt & informatie</td><td>Module A1</td><td>1 juli 2018 (1 oktober 2018 VIPP fase 2)<br><br></td></tr><tr><td></td><td>Module A2</td><td>31 december 2019</td></tr><tr><td></td><td>Module A3</td><td>31 december 2019</td></tr><tr><td>Patiënt & medicatie</td><td>Module B1</td><td>1 juli 2018 (1 januari 2019 VIPP fase 2)</td></tr><tr><td></td><td>Module B2</td><td>31 december 2019</td></tr></tbody></table><p>Een ziekenhuis, dat gebruik wil maken van de subsidieregeling, dient tussen 1 januari 2017 en 31 december 2019 de aanvraag voor het uitvoeren van een VIPP-assessment in te dienen bij een IT-auditor. Het VIPP-assessment voor een module wordt uiterlijk aangevraagd op de dag waarop de betreffende module gerealiseerd moet zijn. Verder kan het VIPP-assessment in één keer worden aangevraagd voor één of meerdere modules mits deze binnen de tijdslijn van de modules vallen.&nbsp;</p>
    )

    describe '.deserializer' do
      it 'converts the html into raw' do
        raw = described_class.deserializer(html)

        expect(raw[:document][:nodes].length).to be 4
        expect(raw[:document][:nodes][2][:type]).to eq 'table'
      end
    end
  end

  context 'with an image' do
    html = %(
      <p>In onderstaand schema is het volledige kwalificatieproces beschreven, inclusief de bijbehorende termijnen/deadlines.&nbsp;</p>
      <div><img src="https://https://via.placeholder.com/150.png"></div>
    )

    describe '.deserializer' do
      it 'converts the html into raw' do
        raw = described_class.deserializer(html)

        expect(raw[:document][:nodes].length).to be 2
        expect(raw[:document][:nodes][1][:type]).to eq 'paragraph'
        expect(raw[:document][:nodes][1][:nodes][0][:type]).to eq 'image'
      end
    end
  end
end
