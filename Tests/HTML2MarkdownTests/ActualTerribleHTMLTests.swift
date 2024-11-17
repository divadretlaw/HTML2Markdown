import XCTest
@testable import HTML2Markdown

final class ActualTerribleHTMLTests: XCTestCase {
    private func doConvert(_ html: String, options: MarkdownGenerator.Options = []) throws -> String {
        return try HTMLParser()
            .parse(html: html)
            .markdownFormatted(options: options)
    }
    
    func test001() throws {
        let html = """
        <p><span><span>Rail replacement bus services for Greater Anglia, London Overground, and TfL Rail will depart from:</span></span></p>
        <p><span><span><span><span>Montfichet Road, Bus Stop W, for Eastbound services - <a href="https://www.nationalrail.co.uk/DR%20A%20Stratford%20CRL-040.pdf">map here</a><span><span><span><span><br />
        <span> </span></span></span></span></span></span></span></span></span></p>
        <p> </p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Rail replacement bus services for Greater Anglia, London Overground, and TfL Rail will depart from:\n\nMontfichet Road, Bus Stop W, for Eastbound services - [map here](https://www.nationalrail.co.uk/DR%20A%20Stratford%20CRL-040.pdf)")
    }
    
    func test002() throws {
        let html = """
        <p><span class="ophr" style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;">Monday-Sunday 07:00-21:50</span><span style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; float: none; display: inline !important; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;"><span class="Apple-converted-space"> </span></span></p><p>Via Network Rail Reception</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Monday-Sunday 07:00-21:50\n\nVia Network Rail Reception")
    }
    
    func test003() throws {
        let html = """
        <span style="font-style: normal; font-weight: normal; font-size: 12px; line-height: 17.01px; font-feature-settings: normal; font-language-override: normal; font-kerning: auto; font-synthesis: weight style; font-variant: normal; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; float: none; display: inline ! important; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;">The ticket office is located on the lower concourse.<br />
        </span>
        """
        XCTAssertEqual(try doConvert(html),
                       "The ticket office is located on the lower concourse.")
    }
    
    func test004() throws {
        let html = """
        <span class="ophr" style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;">Monday-Friday 08:00-21:00</span><span style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; float: none; display: inline !important; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;"><span class="Apple-converted-space"> </span></span><br style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;"><span class="ophr" style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;">Saturday 10:00-18:00</span><span style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; float: none; display: inline !important; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;"><span class="Apple-converted-space"> </span></span><br style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;"><span class="ophr" style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;">Sunday 10:00-18:00</span><span style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; float: none; display: inline !important; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;"><span class="Apple-converted-space"> </span></span>
        """
        XCTAssertEqual(try doConvert(html),
                       "Monday-Friday 08:00-21:00 \nSaturday 10:00-18:00 \nSunday 10:00-18:00")
    }
    
    func test005() throws {
        let html = """
        <p>The toilets can be located on the lower concourse.</p>
        <p>A Changing Place facility is available for use by disabled passengers in London Bridge. The space has a height-adjustable adult-sized changing bench, hoist, shower facility, extra wide rolls of paper, and non-slip floors. </p>
        <p>The facility is located on the on the upper concourse and can be accessed from an accessible lift on the lower concourse, at street level or via a lift on the <a href="https://tfl.gov.uk/modes/tube/">London Underground</a><a href="https://tfl.gov.uk/modes/tube/">.</a>　</p>
        <p>If you, or a passenger you are accompanying, requires use of the Changing Place room, please speak to a member of staff, contact our control centre on 02072341108 or press one of our assistance help points throughout the station so we can help you gain access.</p>
        <p>Changing Places is <a href="https://changingplaces.uktoiletmap.org/toilet/view/1722"><span><span><span lang="EN-GB">a campaign</span></span></span></a><span> on behalf of people who are unable to use standard accessible toilets and are usually more spacious, fitted with advanced equipment and provide the user with a private, comfortable and hygienic space.</span></p>
        """
        XCTAssertEqual(try doConvert(html),
                       "The toilets can be located on the lower concourse.\n\nA Changing Place facility is available for use by disabled passengers in London Bridge. The space has a height-adjustable adult-sized changing bench, hoist, shower facility, extra wide rolls of paper, and non-slip floors.\n\nThe facility is located on the on the upper concourse and can be accessed from an accessible lift on the lower concourse, at street level or via a lift on the [London Underground](https://tfl.gov.uk/modes/tube/)[.](https://tfl.gov.uk/modes/tube/)\n\nIf you, or a passenger you are accompanying, requires use of the Changing Place room, please speak to a member of staff, contact our control centre on 02072341108 or press one of our assistance help points throughout the station so we can help you gain access.\n\nChanging Places is [a campaign](https://changingplaces.uktoiletmap.org/toilet/view/1722) on behalf of people who are unable to use standard accessible toilets and are usually more spacious, fitted with advanced equipment and provide the user with a private, comfortable and hygienic space.")
    }
    
    func test006() throws {
        let html = """
        <span class="ophr" style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;">Monday-Saturday 07:00-22:15</span><span style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; float: none; display: inline !important; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;"><span class="Apple-converted-space"> </span></span><br style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;"><span class="ophr" style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;">Sunday 09:00-20:45</span><span style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; float: none; display: inline !important; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;"><span class="Apple-converted-space"> </span></span><br style="font: 12px/normal Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;"><p style="font: 12px/1.4em Arial, Helvetica, sans-serif; margin: 0px; padding: 0px 0px 1em; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;">Station Reception</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Monday-Saturday 07:00-22:15 \nSunday 09:00-20:45 \n\nStation Reception")
    }
    
    func test007() throws {
        let html = """
        <p>The entrance to the public toilets is on the main concourse opposite platform 18, and these facilities have an accessible toilet and baby changing facilities. There is a another accessible toilet outside exit 3 operated by a RADAR&nbsp;key.</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "The entrance to the public toilets is on the main concourse opposite platform 18, and these facilities have an accessible toilet and baby changing facilities. There is a another accessible toilet outside exit 3 operated by a RADAR\u{00A0}key.")
    }
    
    func test008() throws {
        let html = """
        South Western Railway's waiting room - platform 9/10:
        Monday to Saturday 06:00 to 23:00.
        Sunday 07:00 to 23:00.
        
        Southern's waiting room - platform 13/14:
        7 days a week 05:00 to 23:00
        """
        XCTAssertEqual(try doConvert(html),
                       "South Western Railway's waiting room - platform 9/10: Monday to Saturday 06:00 to 23:00. Sunday 07:00 to 23:00. Southern's waiting room - platform 13/14: 7 days a week 05:00 to 23:00")
    }
    
    func test009() throws {
        let html = """
        <p><span style="font-size:10.0pt">Waiting rooms are on platforms 1, 9/10 and 13/14</span></p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Waiting rooms are on platforms 1, 9/10 and 13/14")
    }
    
    func test010() throws {
        let html = """
        <p>Through services: Grant Road Bus Stop A</p> <p>All arrivals (except via Wandsworth Town): St Johns Hill Bus Stop C</p> <p>Arrivals via Wandsworth Town: Grant Road Bus Stop R</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Through services: Grant Road Bus Stop A\n\nAll arrivals (except via Wandsworth Town): St Johns Hill Bus Stop C\n\nArrivals via Wandsworth Town: Grant Road Bus Stop R")
    }
    
    func test011() throws {
        let html = """
        <p>On the main concourse next to WH Smiths</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "On the main concourse next to WH Smiths")
    }
    
    func test012() throws {
        let html = """
        <p>Luggage received from terminated trains at Birmingham New Street only </p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Luggage received from terminated trains at Birmingham New Street only")
    }
    
    func test013() throws {
        let html = """
        <p><strong>Male</strong>, <strong>Female</strong>, <strong>Accessible</strong> and <strong>Baby Change</strong> facilities are available in all parts of the station. </p>
        <p>These are located between: </p>
        <ul>
         <li>Platforms 2 - 3a (Blue Lounge)</li>
         <li>Platforms 10 - 11a (Yellow Lounge)</li>
         <li>Platforms 10 - 11b (Red Lounge)</li>
        </ul>
        """
        XCTAssertEqual(try doConvert(html),
                       "**Male**, **Female**, **Accessible** and **Baby Change** facilities are available in all parts of the station.\n\nThese are located between:\n\n* Platforms 2 - 3a (Blue Lounge)\n* Platforms 10 - 11a (Yellow Lounge)\n* Platforms 10 - 11b (Red Lounge)")
    }
    
    func test014() throws {
        let html = """
        <p>Monday - Friday, 08:00 - 20:00</p>
          <p>Saturday 09:00 - 16:00</p>
          <p>Sunday 09:00 - 16:00</p>
          <p>Christmas Day and Boxing Day: CLOSED</p>
          <p>0345 744 4422 (option 3, followed by option 3)</p>
          <p>contact@c2crail.co.uk</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Monday - Friday, 08:00 - 20:00\n\nSaturday 09:00 - 16:00\n\nSunday 09:00 - 16:00\n\nChristmas Day and Boxing Day: CLOSED\n\n0345 744 4422 (option 3, followed by option 3)\n\ncontact@c2crail.co.uk")
    }
    
    func test015() throws {
        let html = """
        Closed on Christmas Day and Boxing Day
        """
        XCTAssertEqual(try doConvert(html),
                       "Closed on Christmas Day and Boxing Day")
    }
    
    func test016() throws {
        let html = """
        <p>London Overground Rail Replacement buses:</p>
        <p>Eastbound towards Barking (terminating) at bus stop H in Station Parade.<br />
        </p>
        <p>Westbound towards Walthamstow Central use bus stop K in Station Parade. <br />
        </p>
        <p>c2c Rail Replacement buses outside the front of the station near KFC.</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "London Overground Rail Replacement buses:\n\nEastbound towards Barking (terminating) at bus stop H in Station Parade.\n\nWestbound towards Walthamstow Central use bus stop K in Station Parade.\n\nc2c Rail Replacement buses outside the front of the station near KFC.")
    }
    
    func test017() throws {
        let html = """
        <p style="font-style: normal; font-weight: normal; font-size: 12px; line-height: 1.4em; font-feature-settings: normal; font-language-override: normal; font-kerning: auto; font-synthesis: weight style; font-variant: normal; margin: 0px; padding: 0px 0px 1em; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal;">The travel centre is on the left as you enter through the main entrance.</p> <p style="font-style: normal; font-weight: normal; font-size: 12px; line-height: 1.4em; font-feature-settings: normal; font-language-override: normal; font-kerning: auto; font-synthesis: weight style; font-variant: normal; margin: 0px; padding: 0px 0px 1em; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal;">Advanced bookings are available:</p> <p style="font-style: normal; font-weight: normal; font-size: 12px; line-height: 1.4em; font-feature-settings: normal; font-language-override: normal; font-kerning: auto; font-synthesis: weight style; font-variant: normal; margin: 0px; padding: 0px 0px 1em; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal;"> Monday to Friday - 06:30 to 21:00<br /> Saturday - 08:30 to 21:00<br /> Sunday - 07:30 to 21:00</p> <p style="font-style: normal; font-weight: normal; font-size: 12px; line-height: 1.4em; font-feature-settings: normal; font-language-override: normal; font-kerning: auto; font-synthesis: weight style; font-variant: normal; margin: 0px; padding: 0px 0px 1em; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal;"></p>
        """
        XCTAssertEqual(try doConvert(html),
                       "The travel centre is on the left as you enter through the main entrance.\n\nAdvanced bookings are available:\n\nMonday to Friday - 06:30 to 21:00\n Saturday - 08:30 to 21:00\n Sunday - 07:30 to 21:00")
    }
    
    func test018() throws {
        let html = """
        <span class="ophr" style="text-transform: none; line-height: normal; text-indent: 0px; letter-spacing: normal; font-size: 12px; font-style: normal; font-variant: normal; font-weight: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;">Monday-Sunday 07:00-23:00</span><span style="text-transform: none; line-height: normal; text-indent: 0px; letter-spacing: normal; font-size: 12px; font-style: normal; font-variant: normal; font-weight: normal; word-spacing: 0px; float: none; display: inline !important; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;"><span class="Apple-converted-space"> </span></span><br style="text-transform: none; line-height: normal; text-indent: 0px; letter-spacing: normal; font-size: 12px; font-style: normal; font-variant: normal; font-weight: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;" />
        <p style="margin: 0px; padding: 0px 0px 1em; text-transform: none; line-height: 1.4em; text-indent: 0px; letter-spacing: normal; font-size: 12px; font-style: normal; font-variant: normal; font-weight: normal; word-spacing: 0px; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;">Customers can seek information and assistance from the ticket office or the Mobility Assistance Reception.</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Monday-Sunday 07:00-23:00 \n\nCustomers can seek information and assistance from the ticket office or the Mobility Assistance Reception.")
    }
    
    func test019() throws {
        let html = """
        <p>These are located by the entrance to platforms 1-3</p>
        <p>There are also accessible showers located in the First Class Lounge, shared between Caledonian Sleeper and Avanti West Coast.</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "These are located by the entrance to platforms 1-3\n\nThere are also accessible showers located in the First Class Lounge, shared between Caledonian Sleeper and Avanti West Coast.")
    }
    
    func test020() throws {
        let html = """
        <p>Go to Platform 2, there is a gate adjacent to the station from the main road.&nbsp; </p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Go to Platform 2, there is a gate adjacent to the station from the main road.")
    }
    
    func test021() throws {
        let html = """
        <p dir="LTR">Accessible toilets are located on Platforms 1 and 12.　 A Changing Places facility is located on Platform 12.</p>
        
        <p dir="LTR">There are two dedicated breastfeeding rooms / mother and baby rooms. One within the Ladies toilets on platform one and the other within the public toilets on platform 12.</p>
        
        <p dir="LTR">&nbsp;</p>
        
        <div>&nbsp;</div>
        """
        XCTAssertEqual(try doConvert(html),
                       "Accessible toilets are located on Platforms 1 and 12. A Changing Places facility is located on Platform 12.\n\nThere are two dedicated breastfeeding rooms / mother and baby rooms. One within the Ladies toilets on platform one and the other within the public toilets on platform 12.")
    }
    
    func test022() throws {
        let html = """
        <p>Platforms 1-4 and 11-13, along with the domestic departures areas are managed by High Speed 1 (London and Continental Stations).</p>
        <p>Platforms 5-10 and the international departures areas are managed by <a href="http://www.eurostar.com">Eurostar</a>.</p>
        <p>Platforms A and B and the areas on the low level part of St Pancras, are managed by <a href="https://www.networkrail.co.uk/stations/st-pancras-international/">Network Rail.</a></p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Platforms 1-4 and 11-13, along with the domestic departures areas are managed by High Speed 1 (London and Continental Stations).\n\nPlatforms 5-10 and the international departures areas are managed by [Eurostar](http://www.eurostar.com).\n\nPlatforms A and B and the areas on the low level part of St Pancras, are managed by [Network Rail.](https://www.networkrail.co.uk/stations/st-pancras-international/)")
    }
    
    func test023() throws {
        let html = """
        Ticket machines available 24 hours.
        Travel Centre open 09:00-18:00 Mon-Sat and 10:00-16:00 on Sun. *Sometimes the Travel Centre may be closed during these hours due to Covid-19.
        Customer Information Points open 06:30-20:30 Mon-Sat and 10:00-18:00 on Sun.
        """
        XCTAssertEqual(try doConvert(html, options: .escapeMarkdown),
                       "Ticket machines available 24 hours. Travel Centre open 09:00-18:00 Mon-Sat and 10:00-16:00 on Sun. \\*Sometimes the Travel Centre may be closed during these hours due to Covid-19. Customer Information Points open 06:30-20:30 Mon-Sat and 10:00-18:00 on Sun.")
    }
    
    func test024() throws {
        let html = """
        <p>TfL Customer Services  Tel 0343 222 1234</p>
        <p> </p>
        <p> </p>
        """
        XCTAssertEqual(try doConvert(html),
                       "TfL Customer Services  Tel 0343 222 1234")
    }
    
    func test025() throws {
        let html = """
        <span style="font: 12px/17.01px Arial, Helvetica, sans-serif; text-align: left; text-transform: none; text-indent: 0px; letter-spacing: normal; word-spacing: 0px; float: none; display: inline !important; white-space: normal; font-size-adjust: none; font-stretch: normal; -webkit-text-stroke-width: 0px;">The ticket office is situated on the concourse</span>
        """
        XCTAssertEqual(try doConvert(html),
                       "The ticket office is situated on the concourse")
    }
    
    func test026() throws {
        let html = """
        High Level ScotRail ticket office:
        Mon - Sat 06:00 - 23:25;
        Sun  07:00 - 23:05.
        
        Low Level station ticket office opening times:
        Mon - Sat 06:30 - 23:30;
        Sun  08:15 - 23:30.
        """
        XCTAssertEqual(try doConvert(html),
                       "High Level ScotRail ticket office: Mon - Sat 06:00 - 23:25; Sun 07:00 - 23:05. Low Level station ticket office opening times: Mon - Sat 06:30 - 23:30; Sun 08:15 - 23:30.")
    }
    
    func test027() throws {
        let html = """
        <p>High Level (all destinations): Travel Centre next to Gordon St exit<br />
        High Level (Scottish destinations): Station concourse near Hope St exit<br />
        Low Level: Low level concourse between escalators</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "High Level (all destinations): Travel Centre next to Gordon St exit\n High Level (Scottish destinations): Station concourse near Hope St exit\n Low Level: Low level concourse between escalators")
    }
    
    func test028() throws {
        let html = """
        <p>&nbsp;Baby changing facilities are available at the south central concourse and satellite lounge toilet facility.</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Baby changing facilities are available at the south central concourse and satellite lounge toilet facility.")
    }
    
    func test029() throws {
        let html = """
        <p>Help is available at the Rail Information Point in the centre of the Main Concourse.<br></p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Help is available at the Rail Information Point in the centre of the Main Concourse.")
    }
    
    func test030() throws {
        let html = """
        The toilets including accessible toilets are located next to platform 9. There also toilets on the Mezzanine Level.<br>
        """
        XCTAssertEqual(try doConvert(html),
                       "The toilets including accessible toilets are located next to platform 9. There also toilets on the Mezzanine Level.")
    }
    
    func test031() throws {
        let html = """
        <p>To Raynes Park: Alexandra Road (B235) Bus Stop B</p>
        <p>To Clapham Junction: Alexandra Road (B235) Bus Stop A</p>
        <p>Terminating services from Raynes Park / Surbiton: Wimbledon Bridge (A219) in front of station</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "To Raynes Park: Alexandra Road (B235) Bus Stop B\n\nTo Clapham Junction: Alexandra Road (B235) Bus Stop A\n\nTerminating services from Raynes Park / Surbiton: Wimbledon Bridge (A219) in front of station")
    }
    
    func test032() throws {
        let html = """
        <p>Toilets and accessible toilets are located at the east end of the main concourse.<br />
        In addition, there is also a <a href="https://changingplaces.uktoiletmap.org/">Changing Place</a>&nbsp;facility available. This provides a changing bench, hoist, height adjustable sink and non-slip floors. The Changing place is located by the north entrance to the station, in the same building as the cycle storage facilities. It is on the first floor of the building and has step-free access. Please speak to station staff who will arrange access to the building.<br />
        Changing Places is a campaign on behalf of people who are unable to use standard accessible toilets and are usually more spacious, fitted with advanced equipment and provide the user with a private, comfortable and hygienic space.</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Toilets and accessible toilets are located at the east end of the main concourse.\n In addition, there is also a [Changing Place](https://changingplaces.uktoiletmap.org/)\u{00A0}facility available. This provides a changing bench, hoist, height adjustable sink and non-slip floors. The Changing place is located by the north entrance to the station, in the same building as the cycle storage facilities. It is on the first floor of the building and has step-free access. Please speak to station staff who will arrange access to the building.\n Changing Places is a campaign on behalf of people who are unable to use standard accessible toilets and are usually more spacious, fitted with advanced equipment and provide the user with a private, comfortable and hygienic space.")
    }
    
    func test033() throws {
        let html = """
        <p>Station staffing times may vary, please visit <a href="https://www.merseyrail.org/">Merseyrail.org</a> for up-to-date times.</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Station staffing times may vary, please visit [Merseyrail.org](https://www.merseyrail.org/) for up-to-date times.")
    }
    
    func test034() throws {
        let html = """
        <p>Most rail replacement services depart from the front of the station on Lime Street.</p>
        
        <p>However, <em><strong>Northern </strong></em>rail replacement services depart from outside the station entrance, bus stop opposite the taxi rank on Skelhorne street L3 5GA..</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Most rail replacement services depart from the front of the station on Lime Street.\n\nHowever, ***Northern*** rail replacement services depart from outside the station entrance, bus stop opposite the taxi rank on Skelhorne street L3 5GA..")
    }
    
    func test035() throws {
        let html = """
        <p>Staffed Information Point on main concourse.</p>
          <p>Alternatively Customer Services may be contacted as follows:</p>
          <p> Mondays - Fridays, between 08:00 - 20:00 </p>
          <p>Saturday - Sunday, between 09:00 - 16:00</p>
          <p>Public Holidays, between 09:00 - 16:00</p>
          <p>Closed on Christmas Day and Boxing Day</p>
          <p>Tel: 0345 744 4422 (option 3, followed by option 3)</p>
          <p>Email: contact@c2crail.net</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Staffed Information Point on main concourse.\n\nAlternatively Customer Services may be contacted as follows:\n\nMondays - Fridays, between 08:00 - 20:00\n\nSaturday - Sunday, between 09:00 - 16:00\n\nPublic Holidays, between 09:00 - 16:00\n\nClosed on Christmas Day and Boxing Day\n\nTel: 0345 744 4422 (option 3, followed by option 3)\n\nEmail: contact@c2crail.net")
    }
    
    func test036() throws {
        let html = """
        <ul>
         <li>An accessible, heated&nbsp;waiting room is located on Platform 4.</li>
         <li>The&nbsp;waiting room is open from first to last train.</li>
        </ul>
        """
        XCTAssertEqual(try doConvert(html),
                       "* An accessible, heated\u{00A0}waiting room is located on Platform 4.\n* The\u{00A0}waiting room is open from first to last train.")
    }
    
    func test037() throws {
        let html = """
        <span><span>Rail replacement bus services will depart from:</span></span>
        <ul>
         <li><span><span>Atlanta Boulevard for both Westbound and Eastbound services</span></span></li>
        </ul>
        <p><a href="https://www.nationalrail.co.uk/DR%20I%20Romford%20CRL-040.pdf">Click here for map</a></p>
        <p> </p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Rail replacement bus services will depart from:\n\n* Atlanta Boulevard for both Westbound and Eastbound services\n\n[Click here for map](https://www.nationalrail.co.uk/DR%20I%20Romford%20CRL-040.pdf)")
    }
    
    func test038() throws {
        let html = """
        WC available on Platform 1 and 2<br />
        Accessible Toilet Location - Platform 1
        """
        XCTAssertEqual(try doConvert(html),
                       "WC available on Platform 1 and 2\n Accessible Toilet Location - Platform 1")
    }
    
    func test039() throws {
        let html = """
        <p>The toilets are located on Platform 1. </p>
        <p>Access to the National key toilets must be requested at the Ticket Office window.</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "The toilets are located on Platform 1.\n\nAccess to the National key toilets must be requested at the Ticket Office window.")
    }
    
    func test040() throws {
        let html = """
        <p>This station has heated waiting rooms available. Seating is available at an accessible height in the waiting room and on platforms</p><p>Platform 1 Waiting Room Opening Times - Mon - Fri 05:30- 23:10. Sat&nbsp;&nbsp;05:30- 21:30. Sun 08:45- 22.40</p> <p>Platform 2 waiting Room Opening Times - Mon - Fri 05:30 - 23:20. Sat&nbsp;&nbsp;05:30- 23:10 Sun 08:45- 23:10</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "This station has heated waiting rooms available. Seating is available at an accessible height in the waiting room and on platforms\n\nPlatform 1 Waiting Room Opening Times - Mon - Fri 05:30- 23:10. Sat\u{00A0}\u{00A0}05:30- 21:30. Sun 08:45- 22.40\n\nPlatform 2 waiting Room Opening Times - Mon - Fri 05:30 - 23:20. Sat\u{00A0}\u{00A0}05:30- 23:10 Sun 08:45- 23:10")
    }
    
    func test041() throws {
        let html = """
        <p><a title="Email ScotRail Customer Relations" href="mailto:customer.relations@scotrail.co.uk">customer.relations@scotrail.co.uk</a></p>
        """
        XCTAssertEqual(try doConvert(html),
                       "[customer.relations@scotrail.co.uk](mailto:customer.relations@scotrail.co.uk)")
    }
    
    func test042() throws {
        let html = """
        As part of our COVID-19 response, toilets are opened upon request. The toilets are located on Platform 1. Available during ticket office opening hours.
        """
        XCTAssertEqual(try doConvert(html),
                       "As part of our COVID-19 response, toilets are opened upon request. The toilets are located on Platform 1. Available during ticket office opening hours.")
    }
    
    func test043() throws {
        let html = """
        <p>Pick Up / Drop Off at the bus stop on Station Rd adjacent to M & S (towards York) & pick up / drop off at the bus stop opposite the Arndale Centre (towards Leeds).</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Pick Up / Drop Off at the bus stop on Station Rd adjacent to M & S (towards York) & pick up / drop off at the bus stop opposite the Arndale Centre (towards Leeds).")
    }
    
    func test044() throws {
        let html = """
        <p>Please register your lost property using the form at <a href="https://www.southwesternrailway.com/contact-and-help/lost-property">SWR Lost Property</a>. It can take several days for items to turn up, we will let you know if they do.</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Please register your lost property using the form at [SWR Lost Property](https://www.southwesternrailway.com/contact-and-help/lost-property). It can take several days for items to turn up, we will let you know if they do.")
    }
    
    func test045() throws {
        let html = """
        <p class="MsoNormal">To Cosham: East Street A27 Bus Shelter</p> <p>To Fareham: East Street A27 Bus Shelter by Red Lion Pub</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "To Cosham: East Street A27 Bus Shelter\n\nTo Fareham: East Street A27 Bus Shelter by Red Lion Pub")
    }
    
    func test046() throws {
        let html = """
        <p>To Ascot: Pembroke Broadway Bus Stop A</p> <p>To Aldershot: Pembroke Broadway Bus Stop D</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "To Ascot: Pembroke Broadway Bus Stop A\n\nTo Aldershot: Pembroke Broadway Bus Stop D")
    }
    
    func test047() throws {
        let html = """
        <p>Please visit <a href="https://www.railhelp.co.uk/gwr/">GWR Help & Support</a>. Or contact our social media team @gwrhelp.</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Please visit [GWR Help & Support](https://www.railhelp.co.uk/gwr/). Or contact our social media team @gwrhelp.")
    }
    
    func test048() throws {
        let html = """
        <p><span class="ophr">Monday-Saturday 08:00-20:00</span><span class="apple-converted-space"></span><br /> <span class="ophr">Sunday 10:00-20:00</span><span class="apple-converted-space"></span><br /> <span class="ophr">Bank Holidays 09:00-18:00</span><span class="apple-converted-space"></span></p> <p>The hours shown are for the Customer Relations team on 0345 600 7245 (option 8).</p> <p style="margin: 0in 0in 0pt; line-height: 16.8pt;">Closed on Christmas Day and Boxing Day.</p> <p style="margin: 0in 0in 0pt;"><span></span></p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Monday-Saturday 08:00-20:00\nSunday 10:00-20:00\nBank Holidays 09:00-18:00\n\nThe hours shown are for the Customer Relations team on 0345 600 7245 (option 8).\n\nClosed on Christmas Day and Boxing Day.")
    }
    
    func test049() throws {
        let html = """
        <p>Inside the ferry terminal&nbsp;</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Inside the ferry terminal")
    }
    
    func test050() throws {
        let html = """
        Contact our Customer Relations team directly via the customer webform at <a href="https://tfwrail.wales">www.tfwrail.wales</a>
        """
        XCTAssertEqual(try doConvert(html),
                       "Contact our Customer Relations team directly via the customer webform at [www.tfwrail.wales](https://tfwrail.wales)")
    }
    
    func test051() throws {
        let html = """
        <p>
        </p>
        <p style="margin: 0cm 0cm 0pt; line-height: 16.8pt;"><span lang="EN" style="margin: 0px; font-size: 9pt;">Please contact our Contact Centre
        team on: 0333 311 0039</span>. <span lang="EN" style="margin: 0px; font-size: 9pt;">Who are open during the following times: </span></p>
        <p>
        </p>
        <p style="margin: 0cm 0cm 0pt; line-height: 16.8pt;"><span lang="EN" style="margin: 0px; font-size: 9pt;">Monday to Friday: 07:00 - 19:00
        Saturday and Sunday: 08:00 - 16:00 Bank Holidays: 08:00 - 16:00 except
        Christmas Day and Boxing Day. </span></p>
        <p>
        </p>
        <p><span style="margin: 0px; font-size: 9pt;">**Hednesford Station is accredited by the Secure
        Station Scheme**</span></p>
        <p>
        </p>
        """
        XCTAssertEqual(try doConvert(html, options: .escapeMarkdown),
                       "Please contact our Contact Centre team on: 0333 311 0039. Who are open during the following times:\n\nMonday to Friday: 07:00 - 19:00 Saturday and Sunday: 08:00 - 16:00 Bank Holidays: 08:00 - 16:00 except Christmas Day and Boxing Day.\n\n\\*\\*Hednesford Station is accredited by the Secure Station Scheme\\*\\*")
    }
    
    func test052() throws {
        let html = """
        <p>In the event of engineering the bus/coach will collect from:</p> <p>Towards Rugeley - public service bus stop in between the shops on Cannock Road opposite to Railway View.</p> <p>Towards Walsall/Birmingham - public service bus stop/layby on Cannock Road between Market Street and Railway View junctions.</p>
        """
        XCTAssertEqual(try doConvert(html),
                       "In the event of engineering the bus/coach will collect from:\n\nTowards Rugeley - public service bus stop in between the shops on Cannock Road opposite to Railway View.\n\nTowards Walsall/Birmingham - public service bus stop/layby on Cannock Road between Market Street and Railway View junctions.")
    }
    
    func test053() throws {
        let html = """
        <p>Pick Up / Drop Off on the main road (Rochdale Rd) next to the station service bus stop (18938) towards Todmorden and opposite towards Rochdale. <br />  </p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Pick Up / Drop Off on the main road (Rochdale Rd) next to the station service bus stop (18938) towards Todmorden and opposite towards Rochdale.")
    }
    
    func test054() throws {
        let html = """
        <p><span class="ophr">Monday-Saturday 08:00-20:00</span><span class="apple-converted-space"></span><br /> <span class="ophr">Sunday 10:00-20:00</span><span class="apple-converted-space"></span><br /> <span class="ophr">Bank Holidays 09:00-18:00</span><span class="apple-converted-space"></span></p> <p>The hours shown are for the Customer Relations team on 0345 600 7245 (option 8).</p> <p style="margin: 0in 0in 0pt; line-height: 16.8pt;">Closed on Christmas Day and Boxing Day.</p> <p style="margin: 0in 0in 0pt;"><span></span></p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Monday-Saturday 08:00-20:00\nSunday 10:00-20:00\nBank Holidays 09:00-18:00\n\nThe hours shown are for the Customer Relations team on 0345 600 7245 (option 8).\n\nClosed on Christmas Day and Boxing Day.")
    }
    
    func test055() throws {
        let html = """
        <p><a title="Email ScotRail Customer Relations" href="mailto:customer.relations@scotrail.co.uk">customer.relations@scotrail.co.uk</a></p>
        """
        XCTAssertEqual(try doConvert(html),
                       "[customer.relations@scotrail.co.uk](mailto:customer.relations@scotrail.co.uk)")
    }
    
    func test056() throws {
        let html = """
        <p>
        </p>
        <p style="margin: 0cm 0cm 0pt; line-height: 16.8pt;"><span lang="EN" style="margin: 0px; font-size: 9pt;">Please contact our Contact Centre
        team on: </span><span style="background-position: 0% 0%; margin: 0px; font-size: 9pt; background-repeat: repeat; background-attachment: scroll; background-clip: border-box; background-origin: padding-box; background-size: auto;">0333 311 0006</span>.
        <span lang="EN" style="margin: 0px; font-size: 9pt;">Who are open during
        the following times: </span></p>
        <p>
        <span lang="EN" style="margin: 0px; font-size: 9pt;">Monday to Friday: 07:00 - 19:00 Saturday and
        Sunday: 08:00 - 16:00 Bank Holidays: 08:00 - 16:00 except Christmas Day and
        Boxing Day</span></p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Please contact our Contact Centre team on: 0333 311 0006. Who are open during the following times:\n\nMonday to Friday: 07:00 - 19:00 Saturday and Sunday: 08:00 - 16:00 Bank Holidays: 08:00 - 16:00 except Christmas Day and Boxing Day")
    }
    
    func test057() throws {
        let html = """
        <p>Category B.  </p>
        <p>Platform 1 has step free access and can be reached via a ramp with a moderate gradient. Platform 2 has step free access via a ramp with a moderate gradient. However, to go between the platforms you do have to use the level crossing which is an unsmooth surface.  </p>
        <p>This station doesn't have any tactile paving at the platform edges. <o:p></o:p></p>
        """
        XCTAssertEqual(try doConvert(html),
                       "Category B.\n\nPlatform 1 has step free access and can be reached via a ramp with a moderate gradient. Platform 2 has step free access via a ramp with a moderate gradient. However, to go between the platforms you do have to use the level crossing which is an unsmooth surface.\n\nThis station doesn't have any tactile paving at the platform edges.")
    }
}
