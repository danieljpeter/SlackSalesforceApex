public class SlackBlockKit {

    //mrkdwn formatting: https://api.slack.com/reference/surfaces/formatting
    //block kit builder: https://app.slack.com/block-kit-builder

    //the outermost container for modal view
    //blocks can have different properties, so just storing as Objects
    public class View {
        public String type {get; set;}
        public String callback_id {get; set;}
        public Text title {get; set;}
        public List<Object> blocks {get; set;}
        public view () {
            type = 'modal';
            blocks = new List<Object>();
        }
        public void addBlock(Object obj) {
            blocks.add(obj);
        }
    }

    //the outermost container for message Layout
    //blocks can have different properties, so just storing as Objects
    public class Layout {
        public List<Object> blocks {get; set;}
        public Layout() {
            blocks = new List<Object>();
        }
        public void addBlock(Object obj) {
            blocks.add(obj);
        }
    }

    public class Divider {
        public String type {get; set;}
        public Divider() {
            type = 'divider';
        }
    }

    public class Section {
        public String type {get; set;}
        public String block_id {get; set;}
        public Text text {get; set;}
        public Accessory accessory {get; set;}
        public List<Text> fields {get; set;}
        public Section() {
            type = 'section';
        }
    }

    public class Text {
        public String type {get; set;}
        public String text {get; set;}
        public Boolean emoji {get; set;}
        public Text(String txt) {
            type = 'plain_text';
            text = txt;
        }
        public Text(String typ, String txt) {
            type = typ;
            text = txt;
        }
    }

    public class Accessory {
        public String type {get; set;}
        public String image_url {get; set;}
        public String alt_text {get; set;}
        public Accessory() {
            type = 'image';
        }
    }

    public class Actions {
        String type {get; set;}
        List<Object> elements {get; set;}
        public Actions() {
            type = 'actions';
            elements = new List<Object>();
        }
        public void addAction(Object obj) {
            elements.add(obj);
        }
    }

    public class Button {
        String type {get; set;}
        public Text text {get; set;}
        public String value {get; set;}
        public String action_id {get; set;}

        public Button () {
            type = 'button';
        }
    }



}